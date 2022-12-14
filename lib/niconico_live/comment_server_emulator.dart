import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

class NiconicoLiveCommentServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoLiveCommentServerEmulator() {
    logger = Logger('NiconicoLiveCommentServerEmulator');
  }

  Future<void> start(String host, int port) async {
    final server = await HttpServer.bind(host, port);

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
      (rawMessage) {
        logger.info('server message $rawMessage');

        // skip empty ping packet
        if (rawMessage == '') return;

        final List<dynamic> messages = jsonDecode(rawMessage);
        for (final message in messages) {
          if (message.containsKey('ping')) {
            continue;
          }

          if (message.containsKey('thread')) {
            __startDummyThread(ws);
          }
        }
      },
      onDone: () {
        logger.info('connection ${ws.hashCode} closed with ${ws.closeCode} for ${ws.closeReason}');
      }
    );
  }

  Future<void> __startDummyThread(WebSocket ws) async {
    const thread = 'dummy_thread';

    ws.add(jsonEncode({ 'ping': { 'content': 'rs:0' } }));
    ws.add(jsonEncode({ 'ping': { 'content': 'ps:0' } }));

    ws.add(jsonEncode({
      'thread': {
        'last_res': 10,
        'resultcode': 0,
        'revision': 1,
        'servertime': 1663052000,
        'thread': thread,
        'ticket': 'myticket',
      },
    }));

    for (var commentNo=1; commentNo<=10; commentNo+=1) {
      ws.add(jsonEncode({
        'chat': {
          'anonymity': 1, // optional, only if 184
          'content': 'mycontent $commentNo',
          'date': 1663052000 + commentNo,
          'date_usec': 660000,
          'no': commentNo,
          'premium': 1, // optional
          'thread': thread,
          'mail': '184', // optional, only if 184
          'user_id': '100',
          'vpos': 212814,
        },
      }));
    }

    ws.add(jsonEncode({ 'ping': { 'content': 'pf:0' } }));
    ws.add(jsonEncode({ 'ping': { 'content': 'rf:0' } }));

    for (var commentNo=11; commentNo<=15; commentNo+=1) {
      ws.add(jsonEncode({
        'chat': {
          'anonymity': 1, // optional, only if 184
          'content': 'mycontent $commentNo',
          'date': 1663052000 + commentNo, // utc timestamp
          'date_usec': 660000,
          'no': commentNo,
          'premium': 1, // optional
          'thread': thread,
          'mail': '184', // optional, only if 184
          'user_id': 'dummy_184_user_id',
          'vpos': 212814,
        },
      }));
    }
    for (var commentNo=16; commentNo<=20; commentNo+=1) {
      ws.add(jsonEncode({
        'chat': {
          'content': 'mycontent $commentNo',
          'date': 1663052000 + commentNo, // utc timestamp
          'date_usec': 660000,
          'no': commentNo,
          'thread': thread,
          'user_id': '100',
          'vpos': 212814,
        },
      }));
    }
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/info 8 ???2?????????????????????????????????',
        'date': 1663052000 + 21, // utc timestamp
        'date_usec': 660000,
        'no': 21,
        'premium': 3,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/info 10 ???DUMMY???????????????1????????????????????????',
        'date': 1663052000 + 22, // utc timestamp
        'date_usec': 660000,
        'no': 22,
        'premium': 3,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/spi "???DUMMY????????????????????????????????????"',
        'date': 1663052000 + 23, // utc timestamp
        'date_usec': 660000,
        'no': 23,
        'premium': 3,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
    final nicoAdJson = jsonEncode({
      'version': '1',
      'totalAdPoint': 1000,
      'message': '???????????????1??????DUMMY_USER?????????300pt???????????????????????????',
    });
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/nicoad $nicoAdJson',
        'date': 1663052000 + 24, // utc timestamp
        'date_usec': 660000,
        'no': 24,
        'premium': 3,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/gift gourmet_kiritanpo 100 "DUMMY_USER" 600 "" "???????????????" 1',
        'date': 1663052000 + 25, // utc timestamp
        'date_usec': 660000,
        'no': 25,
        'premium': 3,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
    await Future.delayed(const Duration(seconds: 1));
    ws.add(jsonEncode({
      'chat': {
        'anonymity': 1, // optional, only if 184
        'content': '/disconnect',
        'date': 1663052000 + 26, // utc timestamp
        'date_usec': 660000,
        'no': 26,
        'premium': 2,
        'thread': thread,
        'mail': '184', // optional, only if 184
        'user_id': '100',
        'vpos': 212814,
      },
    }));
  }
}
