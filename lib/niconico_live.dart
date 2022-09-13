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

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('main');

  const userAgent = 'uguisu/0.0.0';

  final livePageServer = NiconicoLivePageServerEmulator();
  try {
    await livePageServer.start('127.0.0.1', 10080);

    final livePageClient = NiconicoLivePageClient();
    final livePage = await livePageClient.get(
      uri: Uri.parse('http://127.0.0.1:10080/'),
      userAgent: userAgent,
    );

    final watchServerWebSocketUrl = livePage.webSocketUrl;

    final watchServer = NiconicoLiveWatchServerEmulator();
    try {
      await watchServer.start('127.0.0.1', 10081);

      final commentServer = NiconicoLiveCommentServerEmulator();
      try {
        await commentServer.start('127.0.0.1', 10082);

        final commentClients = <Future>[];

        final watchClient = NiconicoLiveWatchClient();
        try {
          await watchClient.connect(
            websocketUrl: watchServerWebSocketUrl,
            userAgent: userAgent,
            onRoomMessage: (roomMessage) {
              commentClients.add(
                __startCommentClient(
                  commentServerWebSocketUrl: roomMessage.messageServer.uri,
                  userAgent: userAgent,
                  thread: roomMessage.threadId,
                  threadkey: roomMessage.yourPostKey,
                  onChatMessage: (chat) {
                    logger.info('Chat by user/${chat.userId}: ${chat.content}');
                  },
                )
              );
            },
            onScheduleMessage: (scheduleMessage) {
              logger.info('Schedule: begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
            },
            onStatisticsMessage: (statisticsMessage) {
              logger.info('Statistics: viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
            },
          );

          await Future.delayed(const Duration(seconds: 5));

          await Future.wait(commentClients);
        } finally {
          await watchClient.stop();
        }
      } finally {
        await commentServer.stop();
      }
    } finally {
      await watchServer.stop();
    }
  } finally {
    await livePageServer.stop();
  }


  logger.info('exit');
}
