import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

class NiconicoUserPageServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoUserPageServerEmulator() {
    logger = Logger('NiconicoUserPageServerEmulator');
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
    final initialDataJson = jsonEncode({
      'userDetails': {
        'userDetails': {
          'user': {
            'id': 100,
            'nickname': 'DUMMY',
            'icons': {
              'large': 'http://127.0.0.1:80024/?1600000000', // query: last updated time
            },
          },
        },
      },
    });
    final initialDataJsonSafe = const HtmlEscape().convert(initialDataJson);

    request.response.write('''
<!DOCTYPE html>
<meta charset="utf-8">

<div id="js-initial-userpage-data" data-initial-data="$initialDataJsonSafe"></div>
''');
    request.response.close();
  }
}
