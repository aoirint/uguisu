import 'package:logging/logging.dart';
import 'live_page_server_emulator.dart';
import 'watch_server_emulator.dart';
import 'comment_server_emulator.dart';
import 'user_page_server_emulator.dart';

class NiconicoLiveSimpleServerEmulator {
  NiconicoLivePageServerEmulator? livePageServer;
  NiconicoLiveWatchServerEmulator? watchServer;
  NiconicoLiveCommentServerEmulator? commentServer;
  NiconicoUserPageServerEmulator? userPageServer;

  late Logger logger;

  NiconicoLiveSimpleServerEmulator() {
    logger = Logger('NiconicoLiveSimpleServerEmulator');
  }
  
  Future<void> start() async {
    final livePageServer = NiconicoLivePageServerEmulator();
    await livePageServer.start('127.0.0.1', 10080);
    this.livePageServer = livePageServer;

    final watchServer = NiconicoLiveWatchServerEmulator();
    await watchServer.start('127.0.0.1', 10081);
    this.watchServer = watchServer;

    final commentServer = NiconicoLiveCommentServerEmulator();
    await commentServer.start('127.0.0.1', 10082);
    this.commentServer = commentServer;

    final userPageServer = NiconicoUserPageServerEmulator();
    await userPageServer.start('127.0.0.1', 10083);
    this.userPageServer = userPageServer;
  }

  Future<void> stop() async {
    commentServer?.stop();
    watchServer?.stop();
    livePageServer?.stop();
    userPageServer?.stop();
  }
}
