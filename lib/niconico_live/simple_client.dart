import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/user_page_cache_client.dart';
import 'live_page_client.dart';
import 'watch_client.dart';
import 'comment_client.dart';
import 'user_page_client.dart';
import 'user_icon_cache_client.dart';

class Room {
  RoomMessage roomMessage;
  NiconicoLiveCommentClient commentClient;

  Room({
    required this.roomMessage,
    required this.commentClient,
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
  String userId;
  String userName;
  String giftPoint;
  String unknownArg1;
  String giftName;
  String unknownArg2;
  GiftChatMessage({
    required chatMessage,
    required this.giftId,
    required this.userId,
    required this.userName,
    required this.giftPoint,
    required this.unknownArg1,
    required this.giftName,
    required this.unknownArg2,
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

class NiconicoLiveSimpleClient {
  final String userAgent;

  String? livePageUrl;
  NiconicoLivePage? livePage;
  NiconicoLiveWatchClient? watchClient;
  NiconicoUserIconCacheClient? userIconCacheClient;
  NiconicoUserPageCacheClient? userPageCacheClient;

  late List<Room> rooms;

  Function(ScheduleMessage scheduleMessage)? onScheduleMessage;
  Function(StatisticsMessage statisticsMessage)? onStatisticsMessage;
  Function(BaseChatMessage chatMessage)? onChatMessage;
  Future<Uri> Function(int userId)? getUserPageUri;

  late Logger logger;

  NiconicoLiveSimpleClient({
    required this.userAgent,
  }) {
    rooms = [];
    logger = Logger('NiconicoLiveSimpleClient');
  }

  Future<void> connect({
    required String livePageUrl, // https://live.nicovideo.jp/watch/lv000000000
    required Function(ScheduleMessage scheduleMessage) onScheduleMessage,
    required Function(StatisticsMessage statisticsMessage) onStatisticsMessage,
    required Function(BaseChatMessage chatMessage) onChatMessage,
    required Future<NiconicoUserIconCache?> Function(int userId) userIconLoadCacheOrNull,
    required Future<void> Function(NiconicoUserIconCache userIcon) userIconSaveCache,
    required Future<Uri> Function(int userId) getUserPageUri,
    required Future<NiconicoUserPageCache?> Function(int userId) userPageLoadCacheOrNull,
    required Future<void> Function(NiconicoUserPageCache userPage) userPageSaveCache,
  }) async {
    this.livePageUrl = livePageUrl;
    this.onScheduleMessage = onScheduleMessage;
    this.onStatisticsMessage = onStatisticsMessage;
    this.onChatMessage = onChatMessage;
    this.getUserPageUri = getUserPageUri;

    NiconicoUserIconCacheClient userIconCacheClient = NiconicoUserIconCacheClient(
      userAgent: userAgent,
      loadCacheOrNull: userIconLoadCacheOrNull,
      saveCache: userIconSaveCache,
    );
    this.userIconCacheClient = userIconCacheClient;

    NiconicoUserPageCacheClient userPageCacheClient = NiconicoUserPageCacheClient(
      userAgent: userAgent,
      loadCacheOrNull: userPageLoadCacheOrNull,
      saveCache: userPageSaveCache,
    );
    this.userPageCacheClient = userPageCacheClient;

    NiconicoLivePage livePage = await NiconicoLivePageClient().get(uri: Uri.parse(livePageUrl), userAgent: userAgent);
    this.livePage = livePage;

    NiconicoLiveWatchClient watchClient = NiconicoLiveWatchClient();
    watchClient.connect(
      websocketUrl: livePage.webSocketUrl,
      userAgent: userAgent,
      onRoomMessage: __onRoomMessage,
      onScheduleMessage: __onScheduleMessage,
      onStatisticsMessage: __onStatisticsMessage,
    );

    this.watchClient = watchClient;
  }

  Future<void> stop() async {
    for (final room in rooms) {
      await room.commentClient.stop();
    }

    watchClient?.stop();
  }

  void __onRoomMessage(RoomMessage roomMessage) {
    final commentServerWebSocketUrl = roomMessage.messageServer.uri;
    final thread = roomMessage.threadId;
    final threadkey = roomMessage.yourPostKey;

    final commentClient = NiconicoLiveCommentClient();
    commentClient.connect(
      websocketUrl: commentServerWebSocketUrl,
      userAgent: userAgent,
      thread: thread,
      threadkey: threadkey,
      onChatMessage: __onChatMessage,
    );

    rooms.add(Room(roomMessage: roomMessage, commentClient: commentClient));
  }

  BaseChatMessage __parseChatMessage(ChatMessage chatMessage) {
    final comment = chatMessage.content;
    if (chatMessage.premium == null || chatMessage.premium == 0 || chatMessage.premium == 1) {
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

        final userPageCache = await userPageCacheClient?.loadOrFetchUserPage(userId: userIdInt, userPageUri: userPageUri);
        final userIconCache = userPageCache != null ? await userIconCacheClient?.loadOrFetchIcon(userId: userIdInt, iconUri: Uri.parse(userPageCache.userPage.iconUrl)) : null;

        return CommentUser(userId: userIdInt, userPageCache: userPageCache, userIconCache: userIconCache);
      },);
    }

    if (chatMessage.premium == 2) { // 運営コメント
      if (comment == '/disconnect') { // 番組終了
        return DisconnectChatMessage(chatMessage: chatMessage);
      }
    }
    if (chatMessage.premium == 3) { // コマンド
      if (comment.startsWith('/emotion')) {
        // エモーション
        final emotionName = comment.substring(comment.indexOf(' ')+1).trim();
        return EmotionChatMessage(chatMessage: chatMessage, emotionName: emotionName);
      }

      if (comment.startsWith('/info')) {
        // 3: 延長 | /info 3 30分延長しました
        // 8: ランキング | /info 8 第7位にランクインしました
        // 10: 来場者 | /info 10 「DUMMY」が好きな1人が来場しました | /info 10 ニコニ広告枠から1人が来場しました
        // ?: 好きなものリスト追加
        final infoRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final infoRawMessageSpaceIndex = infoRawMessage.indexOf(' ');

        final infoId = infoRawMessage.substring(0, infoRawMessageSpaceIndex).trim();
        final infoMessage = infoRawMessage.substring(infoRawMessageSpaceIndex+1).trim();

        return InfoChatMessage(chatMessage: chatMessage, infoId: infoId, infoMessage: infoMessage);
      }

      if (comment.startsWith('/spi')) {
        // 放送ネタ
        final spiRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final spiArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(spiRawMessage)[0];
        final spiMessage = spiArgs[0];

        return SpiChatMessage(chatMessage: chatMessage, spiMessage: spiMessage);
      }

      if (comment.startsWith('/nicoad')) {
        // ニコニ広告
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
        // ギフト
        // /gift ギフトID ユーザーID \"ユーザー名\" ギフトポイント \"\" \"ギフト名\" 匿名フラグ？
        final giftRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
        final giftArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(giftRawMessage)[0];

        final giftId = giftArgs[0];
        final userId = giftArgs[1];
        final userName = giftArgs[2];
        final giftPoint = giftArgs[3];
        final unknownArg1 = giftArgs[4];
        final giftName = giftArgs[5];
        final unknownArg2 = giftArgs[6];

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
    final parsedChatMessage = __parseChatMessage(chatMessage);
    onChatMessage?.call(parsedChatMessage);
  }

  void __onScheduleMessage(ScheduleMessage scheduleMessage) {
    onScheduleMessage?.call(scheduleMessage);
  }

  void __onStatisticsMessage(StatisticsMessage statisticsMessage) {
    onStatisticsMessage?.call(statisticsMessage);
  }
}
