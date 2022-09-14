import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

class NiconicoLivePageServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoLivePageServerEmulator() {
    logger = Logger('NiconicoLivePageServerEmulator');
  }

  Future<void> start(String host, int port) async {
    final server = await HttpServer.bind(host, port);

    server
      .listen(
        (request) {
          __handle(request);
        },
        onDone: () {
          logger.info('done');
        },
      );

    logger.info('open http server at http://$host:$port/');
    
    this.server = server;
  }

  Future<void> stop() async {
    logger.info('close http server');
    await server?.close(force: true);
  }

  void __handle(HttpRequest request) {
    final embeddedDataJson = jsonEncode({
      'site': {
        'relive': {
          'webSocketUrl': 'ws://127.0.0.1:10081/', // watch server websocket url
        },
      },
      'program': {
        'title': 'DUMMY_TITLE',
        'supplier': {
          'name': 'DUMMY_NAME',
          'programProviderId': '100',
        },
        'beginTime': 1663156821,
        'endTime': 1663178421,
      },
      'socialGroup': {
        'id': 'co0000000',
        'name': 'DUMMY_COMMUNITY_NAME',
      },
    });
    final embeddedDataJsonSafe = const HtmlEscape().convert(embeddedDataJson);

    request.response.write('''
<!DOCTYPE html>
<meta charset="utf-8">

<script id="embedded-data" data-props="$embeddedDataJsonSafe"></script>
''');
    request.response.close();
  }
}
