import 'dart:io';

import 'package:logging/logging.dart';
import 'live_page_server_emulator.dart';
import 'watch_server_emulator.dart';
import 'comment_server_emulator.dart';
import 'user_page_server_emulator.dart';
import 'user_icon_server_emulator.dart';

class NiconicoLiveSimpleServerEmulator {
  NiconicoLivePageServerEmulator? livePageServer;
  NiconicoLiveWatchServerEmulator? watchServer;
  NiconicoLiveCommentServerEmulator? commentServer;
  NiconicoUserPageServerEmulator? userPageServer;
  NiconicoUserIconServerEmulator? userIconServer;

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

    final userIconServer = NiconicoUserIconServerEmulator();
    await userIconServer.start(
      host: '127.0.0.1',
      port: 10084,
      loadIconFromPath: (path) {
        if (path == '/user_icon/100') {
          return UserIconData(contentType: 'image/png', bytes: File('assets/user_icon_100_150x150.png').readAsBytesSync());
        }
        if (path == '/user_icon/101') {
          return UserIconData(contentType: 'image/png', bytes: File('assets/user_icon_101_150x150.png').readAsBytesSync());
        }

        return null;
      },
    );
    this.userIconServer = userIconServer;
  }

  Future<void> stop() async {
    commentServer?.stop();
    watchServer?.stop();
    livePageServer?.stop();
    userPageServer?.stop();
    userIconServer?.stop();
  }
}
