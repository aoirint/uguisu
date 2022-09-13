import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';

class NiconicoLiveComment {
  final String accountId;
  final String text;
  final DateTime commentedAt; // UTC

  NiconicoLiveComment({required this.accountId, required this.text, required this.commentedAt});
}

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

class NiconicoLiveCommentServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoLiveCommentServerEmulator() {
    logger = Logger('NiconicoLiveCommentServerEmulator');
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
          'anonimity': 1, // optional, only if 184
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

    for (var commentNo=11; commentNo<=20; commentNo+=1) {
      ws.add(jsonEncode({
        'chat': {
          'anonimity': 1, // optional, only if 184
          'content': 'mycontent $commentNo',
          'date': 1663052000 + commentNo, // utc timestamp
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
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class NiconicoLiveWatchClient {
  WebSocket? client;
  final Function(String threadId, String yourPostkey) onRoomMessage;
  late Logger logger;

  NiconicoLiveWatchClient({required this.onRoomMessage}) {
    logger = Logger('NiconicoLiveWatchClient');
  }

  Future<void> connect(String websocketUrl) async {
    logger.info('connect to $websocketUrl');

    WebSocket client = await WebSocket.connect(websocketUrl);
    client.listen(
      (message) {
        __handle(message);
      },
      onError: (error) {
        logger.warning('error: $error');
      },
      onDone: () {
        logger.info('socket closed');
      },
      cancelOnError: true,
    );

    client.add(jsonEncode({
      'type': 'startWatching',
      'data': {
        'reconnect': false,
        'room': {
          'protocol': 'webSocket',
          'commentable': true,
        },
      },
    }));

    this.client = client;
  }

  Future<void> stop() async {
    logger.info('close websocket client');
    await client?.close();
    logger.info('closed');
  }

  void __handle(dynamic rawMessage) {
    WebSocket ws = client!;

    logger.info('message: $rawMessage');

    final Map<String, dynamic> message = jsonDecode(rawMessage);
    final type = message['type'];

    if (type == 'ping') {
      ws.add(jsonEncode({
        'type': 'pong',
      }));
      ws.add(jsonEncode({
        'type': 'keepSeat',
      }));
    } else if (type == 'room') {
      final data = message['data'];
      
      String threadId = data['threadId'];
      String yourPostkey = data['yourPostkey'];

      onRoomMessage(threadId, yourPostkey);
    }
  }
}

class NiconicoLiveCommentClient {
  WebSocket? client;
  ReceivePort? pingTimingReceivePort;
  SendPort? pingTimingSendPort;
  late Logger logger;

  NiconicoLiveCommentClient() {
    logger = Logger('NiconicoLiveCommentClient');
  }

  Future<void> connect({
    required String websocketUrl,
    required String thread,
    String? threadkey,
  }) async {
    logger.info('connect to $websocketUrl');

    WebSocket client = await WebSocket.connect(websocketUrl);
    client.listen(
      (message) {
        __handle(message);
      },
      onError: (error) {
        logger.warning('error: $error');
      },
      onDone: () {
        logger.info('socket closed');
      },
      cancelOnError: true,
    );

    final threadObj = {
      'nicoru': 0,
      'res_from': -150,
      'scores': 1,
      'thread': thread,
      'user_id': 'guest',
      'version': '20061206',
      'with_global': 1,
    };

    if (threadkey != null) {
      threadObj['threadkey'] = threadkey;
    }

    client.add(jsonEncode([
      { 'ping': { 'content': 'rs:0' } },
      { 'ping': { 'content': 'ps:0' } },
      { 'thread': threadObj },
      { 'ping': { 'content': 'pf:0' } },
      { 'ping': { 'content': 'rf:0' } },
    ]));

    this.client = client;

    final pingTimingReceivePort = ReceivePort();
    pingTimingReceivePort.forEach((message) {
      if (message is SendPort) {
        pingTimingSendPort = message; // save the send port to another isolate to notify close event
      }
      if (message == 'ping') {
        client.add(''); // send a ping as an empty packet
      }
    });

    this.pingTimingReceivePort = pingTimingReceivePort;

    Isolate.spawn((sendPort) async {
      var running = true;

      final receivePort = ReceivePort();
      receivePort.forEach((message) {
        if (message == 'close') {
          running = false;
        }
      });

      sendPort.send(receivePort.sendPort);

      var lastPingTime = DateTime.now();

      while (running) {
        var currentTime = DateTime.now();

        // 60 seconds interval
        if (lastPingTime.add(const Duration(seconds: 1)).isBefore(currentTime)) {
          sendPort.send('ping');
          lastPingTime = currentTime;
        }
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }, pingTimingReceivePort.sendPort);
  }

  Future<void> stop() async {
    logger.info('close websocket client');
    await client?.close();
    logger.info('closed');
  }

  void __handle(dynamic rawMessage) {
    logger.info('message: $rawMessage');
  }
}

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
