import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';

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

      await simpleClient.connect(
        livePageUrl: livePageUrl, // for test: http://127.0.0.1:10080, for real case: https://live.nicovideo.jp/watch/lv000000000
        onScheduleMessage: (scheduleMessage) {
          logger.info('Schedule | begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          logger.info('Statistics | viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
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
          } else if (chatMessage is NormalChatMessage) {
            logger.info('Comment | userId=${chatMessage.chatMessage.userId} premium=${chatMessage.chatMessage.premium} content=${chatMessage.chatMessage.content}');
          } else {
            logger.info('Unknown | premium=${chatMessage.chatMessage.premium} content=${chatMessage.chatMessage.content}');
          }
        },
      );

      while (running) {
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
