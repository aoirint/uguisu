import 'package:logging/logging.dart';
import 'live_page_server_emulator.dart';
import 'watch_server_emulator.dart';
import 'comment_server_emulator.dart';

class NiconicoLiveSimpleServerEmulator {
  NiconicoLivePageServerEmulator? livePageServer;
  NiconicoLiveWatchServerEmulator? watchServer;
  NiconicoLiveCommentServerEmulator? commentServer;

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
  }

  Future<void> stop() async {
    commentServer?.stop();
    watchServer?.stop();
    livePageServer?.stop();
  }
}
