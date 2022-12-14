import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/main.dart';
import 'package:uguisu/niconico_live/community_icon_cache_client.dart';
import 'package:uguisu/niconico_live/community_page_cache_client.dart';
import 'package:uguisu/niconico_live/user_page_cache_client.dart';
import 'live_page_client.dart';
import 'watch_client.dart';
import 'comment_client.dart';
import 'user_page_client.dart';
import 'user_icon_cache_client.dart';

class Room {
  RoomMessage roomMessage;
  NiconicoLiveCommentClient commentClient;
  DateTime fetchedAt;

  Room({
    required this.roomMessage,
    required this.commentClient,
    required this.fetchedAt,
  });
}

class CommentUser {
  int userId;
  NiconicoUserPageCache? userPageCache;
  NiconicoUserIconCache? userIconCache;

  CommentUser({
    required this.userId,
    this.userPageCache,
    this.userIconCache,
  });
}

class BaseChatMessage {
  ChatMessage chatMessage;
  BaseChatMessage({
    required this.chatMessage,
  });
}

class NormalChatMessage extends BaseChatMessage {
  CommentUser? commentUser;

  NormalChatMessage({
    required chatMessage,
    this.commentUser,
  }) : super(
    chatMessage: chatMessage,
  );
}

class LazyNormalChatMessage extends BaseChatMessage {
  Future<CommentUser?> Function(LazyNormalChatMessage chatMessage) resolveCommentUser;

  LazyNormalChatMessage({
    required chatMessage,
    required this.resolveCommentUser,
  }) : super(
    chatMessage: chatMessage,
  );

  Future<NormalChatMessage> resolve() async {
    return NormalChatMessage(chatMessage: chatMessage, commentUser: await resolveCommentUser(this));
  }
}

class EmotionChatMessage extends BaseChatMessage {
  String emotionName;
  EmotionChatMessage({
    required chatMessage,
    required this.emotionName,
  }) : super(
    chatMessage: chatMessage,
  );
}

class InfoChatMessage extends BaseChatMessage {
  String infoId;
  String infoMessage;
  InfoChatMessage({
    required chatMessage,
    required this.infoId,
    required this.infoMessage,
  }) : super(
    chatMessage: chatMessage,
  );
}

class SpiChatMessage extends BaseChatMessage {
  String spiMessage;
  SpiChatMessage({
    required chatMessage,
    required this.spiMessage,
  }) : super(
    chatMessage: chatMessage,
  );
}

class NicoadChatMessage extends BaseChatMessage {
  int totalAdPoint;
  String nicoadMessage;
  NicoadChatMessage({
    required chatMessage,
    required this.totalAdPoint,
    required this.nicoadMessage,
  }) : super(
    chatMessage: chatMessage,
  );
}

class GiftChatMessage extends BaseChatMessage {
  String giftId;
  int? userId;
  String userName;
  String giftPoint;
  String unknownArg1;
  String giftName;
  String? unknownArg2;
  GiftChatMessage({
    required chatMessage,
    required this.giftId,
    this.userId,
    required this.userName,
    required this.giftPoint,
    required this.unknownArg1,
    required this.giftName,
    this.unknownArg2,
  }) : super(
    chatMessage: chatMessage,
  );
}

class DisconnectChatMessage extends BaseChatMessage {
  DisconnectChatMessage({
    required chatMessage,
  }) : super(
    chatMessage: chatMessage,
  );
}

class UnknownChatMessage extends BaseChatMessage {
  UnknownChatMessage({
    required chatMessage,
  }) : super(
    chatMessage: chatMessage,
  );
}

class NoWatchWebSocketUrlFoundException implements Exception {
  String message;
  NoWatchWebSocketUrlFoundException(this.message);
}

class NiconicoLiveSimpleClient {
  final String userAgent;

  NiconicoLoginCookie? loginCookie;

  Future<Uri> Function(int userId)? getUserPageUri;
  NiconicoUserPageCacheClient? userPageCacheClient;
  NiconicoUserIconCacheClient? userIconCacheClient;
  
  Future<Uri> Function(String communityId)? getCommunityPageUri;
  NiconicoCommunityPageCacheClient? communityPageCacheClient;
  NiconicoCommunityIconCacheClient? communityIconCacheClient;

  String? livePageUrl;
  NiconicoLivePage? livePage;
  NiconicoLiveWatchClient? watchClient;

  late List<Room> rooms;

  Function(ScheduleMessage scheduleMessage)? onScheduleMessage;
  Function(StatisticsMessage statisticsMessage)? onStatisticsMessage;
  Function(BaseChatMessage chatMessage)? onChatMessage;
  Function(int rvalue)? onRFrameClosed;

  late Logger logger;

  NiconicoLiveSimpleClient({
    required this.userAgent,
  }) {
    rooms = [];
    logger = Logger('NiconicoLiveSimpleClient');
  }

  Future<void> initialize({
    NiconicoLoginCookie? loginCookie,
    required Future<Uri> Function(int userId) getUserPageUri,
    required Future<NiconicoUserPageCache?> Function(int userId) userPageLoadCacheOrNull,
    required Future<void> Function(NiconicoUserPageCache userPage) userPageSaveCache,
    required Future<NiconicoUserIconCache?> Function(int userId) userIconLoadCacheOrNull,
    required Future<void> Function(NiconicoUserIconCache userIcon) userIconSaveCache,
    required Future<Uri> Function(String communityId) getCommunityPageUri,
    required Future<NiconicoCommunityPageCache?> Function(String communityId) communityPageLoadCacheOrNull,
    required Future<void> Function(NiconicoCommunityPageCache communityPage) communityPageSaveCache,
    required Future<NiconicoCommunityIconCache?> Function(String communityId) communityIconLoadCacheOrNull,
    required Future<void> Function(NiconicoCommunityIconCache communityIcon) communityIconSaveCache,
  }) async {
    this.loginCookie = loginCookie;
    this.getUserPageUri = getUserPageUri;

    userPageCacheClient = NiconicoUserPageCacheClient(
      cookieJar: loginCookie?.cookieJar,
      userAgent: userAgent,
      loadCacheOrNull: userPageLoadCacheOrNull,
      saveCache: userPageSaveCache,
    );

    userIconCacheClient = NiconicoUserIconCacheClient(
      cookieJar: loginCookie?.cookieJar,
      userAgent: userAgent,
      loadCacheOrNull: userIconLoadCacheOrNull,
      saveCache: userIconSaveCache,
    );

    this.getCommunityPageUri = getCommunityPageUri;

    communityPageCacheClient = NiconicoCommunityPageCacheClient(
      cookieJar: loginCookie?.cookieJar,
      userAgent: userAgent,
      loadCacheOrNull: communityPageLoadCacheOrNull,
      saveCache: communityPageSaveCache,
    );

    communityIconCacheClient = NiconicoCommunityIconCacheClient(
      userAgent: userAgent,
      loadCacheOrNull: communityIconLoadCacheOrNull,
      saveCache: communityIconSaveCache,
    );
  }

  Future<void> fetchLivePage({
    required String livePageUrl, // https://live.nicovideo.jp/watch/lv000000000
    required Function(ScheduleMessage scheduleMessage) onScheduleMessage,
    required Function(StatisticsMessage statisticsMessage) onStatisticsMessage,
    required Function(BaseChatMessage chatMessage) onChatMessage,
    Function(int rvalue)? onRFrameClosed,
  }) async {
    this.livePageUrl = livePageUrl;
    this.onScheduleMessage = onScheduleMessage;
    this.onStatisticsMessage = onStatisticsMessage;
    this.onChatMessage = onChatMessage;
    this.onRFrameClosed = onRFrameClosed;

    NiconicoLivePage livePage = await NiconicoLivePageClient().get(
      uri: Uri.parse(livePageUrl),
      cookieJar: loginCookie?.cookieJar,
      userAgent: userAgent,
    );
    this.livePage = livePage;

    // ????????????: ???????????????????????????????????????????????????????????????????????????
    if (livePage.webSocketUrl == '') {
      throw NoWatchWebSocketUrlFoundException('No watch web socket url found. Maybe you have no access to the requested program.');
    }
  }

  Future<void> connect() async {
    if (livePage == null) {
      throw Exception('Live page must be set before connect');
    }

    NiconicoLiveWatchClient watchClient = NiconicoLiveWatchClient();
    await watchClient.connect(
      websocketUrl: livePage!.webSocketUrl,
      userAgent: userAgent,
      onRoomMessage: __onRoomMessage,
      onScheduleMessage: __onScheduleMessage,
      onStatisticsMessage: __onStatisticsMessage,
    );

    this.watchClient = watchClient;
  }

  Future<void> disconnect() async {
    for (final room in rooms) {
      await room.commentClient.stop();
    }

    watchClient?.stop();
  }

  void __onRoomMessage(RoomMessage roomMessage) {
    final commentServerWebSocketUrl = roomMessage.messageServer.uri;
    final thread = roomMessage.threadId;
    final threadkey = roomMessage.yourPostKey;
    final fetchedAt = DateTime.now().toUtc();

    final commentClient = NiconicoLiveCommentClient();
    commentClient.connect(
      websocketUrl: commentServerWebSocketUrl,
      userAgent: userAgent,
      thread: thread,
      threadkey: threadkey,
      userId: loginCookie?.userId,
      onChatMessage: __onChatMessage,
      onRFrameClosed: onRFrameClosed,
    );

    rooms.add(Room(roomMessage: roomMessage, commentClient: commentClient, fetchedAt: fetchedAt));
  }

  BaseChatMessage parseChatMessage(ChatMessage chatMessage) {
    final comment = chatMessage.content;
    if (
      chatMessage.premium == null || // ????????????
      chatMessage.premium == 0 || // ??????
      chatMessage.premium == 1 || // ?????????????????????
      (chatMessage.anonymity == null && chatMessage.premium == 3) // ?????????????????????
    ) {
      return LazyNormalChatMessage(chatMessage: chatMessage, resolveCommentUser: (chatMessage) async {
        final is184 = chatMessage.chatMessage.anonymity;
        if (is184 == 1) {
          return null;
        }

        final userIdInt = int.parse(chatMessage.chatMessage.userId);

        final userPageUri = await getUserPageUri?.call(userIdInt);
        if (userPageUri == null) {
          throw Exception('getUserPageUri != null');
        }
        if (userPageCacheClient == null) { throw Exception('userPageCacheClient != null'); }
        if (userIconCacheClient == null) { throw Exception('userIconCacheClient != null'); }

        final userPageCache = await userPageCacheClient!.loadOrFetchUserPage(userId: userIdInt, userPageUri: userPageUri);
        final userIconCache = await userIconCacheClient!.loadOrFetchIcon(userId: userIdInt, iconUri: Uri.parse(userPageCache.userPage.iconUrl!));

        return CommentUser(userId: userIdInt, userPageCache: userPageCache, userIconCache: userIconCache);
      },);
    }

    if (chatMessage.premium == 2) { // ??????????????????
      if (comment == '/disconnect') { // ????????????
        return DisconnectChatMessage(chatMessage: chatMessage);
      }
    }
    if (chatMessage.premium == 3) { // ????????????
      if (comment.startsWith('/emotion')) {
        // ??????????????????
        final emotionName = comment.substring(comment.indexOf(' ')+1).trim();
        return EmotionChatMessage(chatMessage: chatMessage, emotionName: emotionName);
      }

      if (comment.startsWith('/info')) {
        // 3: ?????? | /info 3 30?????????????????????
        // 8: ??????????????? | /info 8 ???7?????????????????????????????????
        // 10: ????????? | /info 10 ???DUMMY???????????????1???????????????????????? | /info 10 ????????????????????????1????????????????????????
        // ?: ??????????????????????????????
        final infoRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final infoRawMessageSpaceIndex = infoRawMessage.indexOf(' ');

        final infoId = infoRawMessage.substring(0, infoRawMessageSpaceIndex).trim();
        final infoMessage = infoRawMessage.substring(infoRawMessageSpaceIndex+1).trim();

        return InfoChatMessage(chatMessage: chatMessage, infoId: infoId, infoMessage: infoMessage);
      }

      if (comment.startsWith('/spi')) {
        // ????????????
        final spiRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final spiArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(spiRawMessage)[0];
        final spiMessage = spiArgs[0];

        return SpiChatMessage(chatMessage: chatMessage, spiMessage: spiMessage);
      }

      if (comment.startsWith('/nicoad')) {
        // ???????????????
        final nicoAdRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final nicoAdMessage = jsonDecode(nicoAdRawMessage);

        final nicoAdVersion = nicoAdMessage['version'];
        if (nicoAdVersion != '1') {
          logger.warning('Unsupported /nicoad version: $nicoAdVersion');
        }

        final totalAdPoint = nicoAdMessage['totalAdPoint'];
        final nicoadMessage = nicoAdMessage['message'];

        return NicoadChatMessage(chatMessage: chatMessage, totalAdPoint: totalAdPoint, nicoadMessage: nicoadMessage);
      }

      if (comment.startsWith('/gift')) {
        // ?????????
        // ???????????????(6???):  /gift gourmet_zundamoti NULL \"?????????\" 300 \"\" \"????????????\"
        // ??????????????????(7???): /gift gourmet_kiritanpo 100 "DUMMY_USER" 600 "" "???????????????" 1
        //                   /gift ?????????ID ????????????ID \"???????????????\" ????????????????????? \"\" \"????????????\" 1
        final giftRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final giftArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(giftRawMessage)[0];

        final giftId = giftArgs[0];
        final userId = giftArgs[1] != 'NULL' ? int.parse(giftArgs[1]) : null;
        final userName = giftArgs[2];
        final giftPoint = giftArgs[3];
        final unknownArg1 = giftArgs[4];
        final giftName = giftArgs[5];
        final unknownArg2 = giftArgs.length > 6 ? giftArgs[6] : null;

        return GiftChatMessage(
          chatMessage: chatMessage,
          giftId: giftId,
          userId: userId,
          userName: userName,
          giftPoint: giftPoint,
          unknownArg1: unknownArg1,
          giftName: giftName,
          unknownArg2: unknownArg2,
        );
      }
    }

    return UnknownChatMessage(chatMessage: chatMessage);
  }

  void __onChatMessage(ChatMessage chatMessage) {
    final parsedChatMessage = parseChatMessage(chatMessage);
    onChatMessage?.call(parsedChatMessage);
  }

  void __onScheduleMessage(ScheduleMessage scheduleMessage) {
    onScheduleMessage?.call(scheduleMessage);
  }

  void __onStatisticsMessage(StatisticsMessage statisticsMessage) {
    onStatisticsMessage?.call(statisticsMessage);
  }
}
