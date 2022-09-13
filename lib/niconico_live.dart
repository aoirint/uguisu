import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';

Future<void> __startCommentClient({
  required String thread,
  String? threadkey,
}) async {
  final commentClient = NiconicoLiveCommentClient();
  try {
    await commentClient.connect(
      websocketUrl: "ws://127.0.0.1:10081/",
      thread: thread,
      threadkey: threadkey,
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

  final watchServer = NiconicoLiveWatchServerEmulator();
  try {
    await watchServer.start("127.0.0.1", 10080);

    final commentServer = NiconicoLiveCommentServerEmulator();
    try {
      await commentServer.start("127.0.0.1", 10081);

      final commentClients = <Future>[];

      final watchClient = NiconicoLiveWatchClient(
        onRoomMessage: (threadId, yourPostkey) {
          commentClients.add(
            __startCommentClient(
              thread: threadId,
              threadkey: yourPostkey,
            )
          );
        },
      );
      try {
        await watchClient.connect("ws://127.0.0.1:10080/");

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

  logger.info('exit');
}
