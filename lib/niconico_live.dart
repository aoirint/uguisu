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
      var running = true;
      var finishedAt = DateTime.now().add(const Duration(seconds: 120));

      await simpleClient.connect(
        livePageUrl: 'https://live.nicovideo.jp/watch/lv338472221',
        onScheduleMessage: (scheduleMessage) {
          logger.info('Schedule: begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          logger.info('Statistics: viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
          logger.info('Chat by user/${chatMessage.userId}: ${chatMessage.content}');

          if (chatMessage.premium == 2) { // 運営コメント
            if (chatMessage.content == '/disconnect') { // 番組終了
              running = false;
            }
          }
          if (chatMessage.premium == 3) { // コマンド
            final match = RegExp(r'^/emotion (.+)$').firstMatch(chatMessage.content);
            if (match != null) {
              final emotionName = match.group(1);

              logger.info('Emotion $emotionName');
            }
          }
        },
      );

      while (running) {
        if (finishedAt.isBefore(DateTime.now())) {
          running = false;
          break;
        }
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
