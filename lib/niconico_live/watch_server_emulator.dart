import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

class NiconicoLiveWatchServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoLiveWatchServerEmulator() {
    logger = Logger('NiconicoLiveWatchServerEmulator');
  }

  Future<void> start(String host, int port) async {
    final server = await HttpServer.bind(host ,port);

    server
      .where((request) => request.uri.path == '/')
      .transform(WebSocketTransformer())
      .listen(
        (ws) {
          __handle(ws);
        },
        onDone: () {
          logger.info('done');
        },
      );

    logger.info('open websocket server at ws://$host:$port/');
    
    this.server = server;
  }

  Future<void> stop() async {
    logger.info('close websocket server');
    await server?.close(force: true);
  }

  void __handle(WebSocket ws) {
    logger.info('new connection: ${ws.hashCode}');

    ws.listen(
      (message) {
        logger.info('server message $message');

        final Map<String, dynamic> data = jsonDecode(message);
        final type = data['type'];

        if (type == 'startWatching') {
          ws.add(jsonEncode({
            'type': 'room',
            'data': {
              'isFirst': true,
              'messageServer': {
                'type': '',
                'uri': '',
              },
              'name': '',
              'threadId': '',
              'vposBaseTime': '',
              'waybackkey': '',
              'yourPostkey': '',
            },
          }));
        } else if (type == 'pong') {
        } else if (type == 'keepSeat') {
        }
      },
      onDone: () {
        logger.info('connection ${ws.hashCode} closed with ${ws.closeCode} for ${ws.closeReason}');
      }
    );
  }
}
