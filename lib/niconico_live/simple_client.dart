import 'package:logging/logging.dart';
import 'live_page_client.dart';
import 'watch_client.dart';
import 'comment_client.dart';

class Room {
  RoomMessage roomMessage;
  NiconicoLiveCommentClient commentClient;

  Room({
    required this.roomMessage,
    required this.commentClient,
  });
}

class NiconicoLiveSimpleClient {
  final String userAgent;

  String? livePageUrl;
  NiconicoLivePage? livePage;
  NiconicoLiveWatchClient? watchClient;
  late List<Room> rooms;

  Function(ScheduleMessage scheduleMessage)? onScheduleMessage;
  Function(StatisticsMessage statisticsMessage)? onStatisticsMessage;
  Function(ChatMessage chatMessage)? onChatMessage;

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
    required Function(ChatMessage chatMessage) onChatMessage,
  }) async {
    this.livePageUrl = livePageUrl;
    this.onScheduleMessage = onScheduleMessage;
    this.onStatisticsMessage = onStatisticsMessage;
    this.onChatMessage = onChatMessage;

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

  void __onChatMessage(ChatMessage chatMessage) {
    onChatMessage?.call(chatMessage);
  }

  void __onScheduleMessage(ScheduleMessage scheduleMessage) {
    onScheduleMessage?.call(scheduleMessage);
  }

  void __onStatisticsMessage(StatisticsMessage statisticsMessage) {
    onStatisticsMessage?.call(statisticsMessage);
  }
}
