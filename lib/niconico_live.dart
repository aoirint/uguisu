import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';
import 'package:uguisu/niconico_live/user_icon_cache_client.dart';
import 'package:uguisu/niconico_live/user_icon_client.dart';
import 'package:uguisu/niconico_live/user_page_client.dart';
import 'package:uguisu/niconico_live/user_page_cache_client.dart';

Future<void> __startCommentClient({
  required String commentServerWebSocketUrl,
  required String userAgent,
  required String thread,
  String? threadkey,
  required Function(ChatMessage) onChatMessage,
}) async {
  final commentClient = NiconicoLiveCommentClient();
  try {
    await commentClient.connect(
      websocketUrl: commentServerWebSocketUrl,
      userAgent: userAgent,
      thread: thread,
      threadkey: threadkey,
      onChatMessage: onChatMessage,
    );

    await Future.delayed(const Duration(seconds: 3));
  } finally {
    await commentClient.stop();
  }
}

Future<void> main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('main');

  if (args.isEmpty) {
    throw Exception('Usage: dart run lib/niconico_live.dart livePageUrl');
  }
  final livePageUrl = args[0];
  logger.info('Live Page URL: $livePageUrl');

  const userAgent = 'uguisu/0.0.0';

  Future<Uri> getUserPageUri(int userId) async {
    if (livePageUrl.startsWith('https://live.nicovideo.jp/watch/')) {
      return Uri.parse('https://www.nicovideo.jp/user/$userId');
    }
    return Uri.parse('http://127.0.0.1:10083/user_page/$userId');
  }

  final simpleServer = NiconicoLiveSimpleServerEmulator();
  final simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);
  try {
    await simpleServer.start();
    try {
      var running = true;
      // var finishedAt = DateTime.now().add(const Duration(seconds: 120));

      // Akashic
      // ?: 放送者フォロー
      // ?: ニコるの勢い順並び替え
      var chatMessages = [];
      var nextChatMessageIndex = 0;

      await simpleClient.connect(
        livePageUrl: livePageUrl, // for test: http://127.0.0.1:10080, for real case: https://live.nicovideo.jp/watch/lv000000000
        onScheduleMessage: (scheduleMessage) {
          logger.info('Schedule | begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          logger.info('Statistics | viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
          chatMessages.add(chatMessage);
        },
        userIconLoadCacheOrNull: (userId) async {
          final userIconJsonFile = File('cache/user_icon/$userId.json');
          if (! await userIconJsonFile.exists()) {
            logger.warning('Cache-miss for user/$userId. User icon json not exists');
            return null;
          }

          final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
          final userIconJson = jsonDecode(userIconRawJson);

          if (userIconJson['version'] != '1') {
            logger.warning('Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
            return null;
          }

          final userIdInJson = userIconJson['userId'];
          if (userIdInJson != userId) {
            throw Exception('Invalid user icon json. userId does not match. given: $userId, json: $userIdInJson');
          }

          final iconUri = Uri.parse(userIconJson['iconUri']);
          final String contentType = userIconJson['contentType'];
          final iconUploadedAt = userIconJson['iconUploadedAt'] != null ? DateTime.parse(userIconJson['iconUploadedAt']) : null;
          final iconFetchedAt = DateTime.parse(userIconJson['iconFetchedAt']);
          final String iconPath = userIconJson['iconPath'];

          final iconFile = File(iconPath);
          if (! await iconFile.exists()) {
            logger.warning('Unexpected cache-miss for user/$userId. User icon image not exists');
            return null;
          }

          final iconBytes = await iconFile.readAsBytes();

          return NiconicoUserIconCache(
            userId: userId,
            userIcon: NiconicoUserIcon(
              iconUri: iconUri,
              contentType: contentType,
              iconBytes: iconBytes,
            ),
            iconUploadedAt: iconUploadedAt,
            iconFetchedAt: iconFetchedAt,
          );
        },
        userIconSaveCache: (userIcon) async {
          final userId = userIcon.userId;
          final contentType = userIcon.userIcon.contentType;

          String? iconFileNameSuffix;
          if (contentType == 'image/png') iconFileNameSuffix = '.png';
          if (contentType == 'image/jpeg') iconFileNameSuffix = '.jpg';
          if (contentType == 'image/gif') iconFileNameSuffix = '.gif';
          if (iconFileNameSuffix == null) {
            throw Exception('Unsupported content type: $contentType');
          }

          final iconFile = File('cache/user_icon/$userId$iconFileNameSuffix');
          await iconFile.parent.create(recursive: true);
          await iconFile.writeAsBytes(userIcon.userIcon.iconBytes, flush: true);

          final userIconJsonFile = File('cache/user_icon/$userId.json');
          final userIconRawJson = jsonEncode({
            'version': '1',
            'userId': userId,
            'iconUri': userIcon.userIcon.iconUri.toString(),
            'contentType': userIcon.userIcon.contentType,
            'iconUploadedAt': userIcon.iconUploadedAt?.toIso8601String(),
            'iconFetchedAt': userIcon.iconFetchedAt.toIso8601String(),
            'iconPath': iconFile.path,
          });

          await userIconJsonFile.writeAsString(userIconRawJson, encoding: utf8, flush: true);
        },
        getUserPageUri: getUserPageUri,
        userPageLoadCacheOrNull: (userId) async {
          final userPageJsonFile = File('cache/user_page/$userId.json');
          if (! await userPageJsonFile.exists()) {
            logger.warning('Cache-miss for user/$userId. User page json not exists');
            return null;
          }

          final userPageRawJson = await userPageJsonFile.readAsString(encoding: utf8);
          final userPageJson = jsonDecode(userPageRawJson);

          if (userPageJson['version'] != '1') {
            logger.warning('Unsupported user page json version. Ignore this: ${userPageJsonFile.path}');
            return null;
          }

          final userIdInJson = userPageJson['userId'];
          if (userIdInJson != userId) {
            throw Exception('Invalid user page json. userId does not match. given: $userId, json: $userIdInJson');
          }

          final nickname = userPageJson['nickname'];
          final iconUrl = userPageJson['iconUrl'];
          final pageFetchedAt = DateTime.parse(userPageJson['pageFetchedAt']);

          return NiconicoUserPageCache(
            userId: userId,
            userPage: NiconicoUserPage(
              id: userId,
              nickname: nickname,
              iconUrl: iconUrl,
            ),
            pageFetchedAt: pageFetchedAt,
          );
        },
        userPageSaveCache: (userPage) async {
          final userId = userPage.userId;

          final userPageJsonFile = File('cache/user_page/$userId.json');
          await userPageJsonFile.parent.create(recursive: true);
          final userPageRawJson = jsonEncode({
            'version': '1',
            'userId': userId,
            'nickname': userPage.userPage.nickname,
            'iconUrl': userPage.userPage.iconUrl,
            'pageFetchedAt': userPage.pageFetchedAt.toIso8601String(),
          });

          await userPageJsonFile.writeAsString(userPageRawJson, encoding: utf8, flush: true);
        },
      );

      while (running) {
        for (; nextChatMessageIndex<chatMessages.length; nextChatMessageIndex+=1) {
          final chatMessage = chatMessages[nextChatMessageIndex];

          if (chatMessage is DisconnectChatMessage) {
            running = false;
          } else if (chatMessage is EmotionChatMessage) {
            logger.info('Emotion | ${chatMessage.emotionName}');
          } else if (chatMessage is InfoChatMessage) {
            logger.info('Info | infoId=${chatMessage.infoId} infoMessage=${chatMessage.infoMessage}');
          } else if (chatMessage is SpiChatMessage) {
            logger.info('Spi | spiMessage=${chatMessage.spiMessage}');
          } else if (chatMessage is NicoadChatMessage) {
            logger.info('Nicoad | totalAdPoint=${chatMessage.totalAdPoint} message=${chatMessage.nicoadMessage}');
          } else if (chatMessage is GiftChatMessage) {
            logger.info('Gift | giftId=${chatMessage.giftId} userId=${chatMessage.userId} userName=${chatMessage.userName} giftPoint=${chatMessage.giftPoint} unknownArg1=${chatMessage.unknownArg1} giftName=${chatMessage.giftName} unknownArg2=${chatMessage.unknownArg2}');
          } else if (chatMessage is LazyNormalChatMessage) {
            final cm = await chatMessage.resolve();
            logger.info('Comment | userId=${cm.chatMessage.userId} premium=${cm.chatMessage.premium} nickname=${cm.commentUser?.userPageCache?.userPage.nickname} content=${cm.chatMessage.content} iconContentType=${cm.commentUser?.userIconCache?.userIcon.contentType} iconBytesLength=${cm.commentUser?.userIconCache?.userIcon.iconBytes.length}');
          } else {
            logger.info('Unknown | premium=${chatMessage.chatMessage.premium} content=${chatMessage.chatMessage.content}');
          }
        }
        // if (finishedAt.isBefore(DateTime.now())) {
        //   running = false;
        //   break;
        // }
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } finally {
      await simpleClient.stop();
    }
  } finally {
    await simpleServer.stop();
  }

  logger.info('exit');
}
