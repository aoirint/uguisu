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

  final simpleServer = NiconicoLiveSimpleServerEmulator();
  final simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);
  try {
    await simpleServer.start();
    try {
      await simpleClient.connect(
        livePageUrl: 'http://127.0.0.1:10080',
        onScheduleMessage: (scheduleMessage) {
          logger.info('Schedule: begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          logger.info('Statistics: viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
          logger.info('Chat by user/${chatMessage.userId}: ${chatMessage.content}');
        },
      );

      await Future.delayed(const Duration(seconds: 5));
    } finally {
      await simpleClient.stop();
    }
  } finally {
    await simpleServer.stop();
  }

  logger.info('exit');
}
