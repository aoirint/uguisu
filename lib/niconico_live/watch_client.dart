import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';

class KeepSeatIsolateOptions {
  SendPort sendPort;
  Duration keepSeatInterval;

  KeepSeatIsolateOptions({required this.sendPort, required this.keepSeatInterval});
}

class NiconicoLiveWatchClient {
  WebSocket? client;
  final Function(String threadId, String yourPostkey) onRoomMessage;
  ReceivePort? keepSeatTimingReceivePort;
  SendPort? keepSeatTimingSendPort;
  Isolate? keepSeatTimingIsolate;
  Duration keepSeatInterval;
  late Logger logger;

  NiconicoLiveWatchClient({
    required this.onRoomMessage,
    this.keepSeatInterval = const Duration(seconds: 60),
  }) {
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

    final keepSeatTimingReceivePort = ReceivePort();
    keepSeatTimingReceivePort.listen((message) {
      if (message is SendPort) {
        keepSeatTimingSendPort = message; // save the send port to another isolate to notify close event
      }
      if (message == 'keepSeat') {
        client.add(jsonEncode({ 'type': 'keepSeat' })); // send a ping as an empty packet
      }
    });

    this.keepSeatTimingReceivePort = keepSeatTimingReceivePort;

    keepSeatTimingIsolate = await Isolate.spawn((options) async {
      final sendPort = options.sendPort;
      
      var running = true;

      final receivePort = ReceivePort();
      receivePort.listen((message) {
        if (message == 'close') {
          running = false;
        }
      });

      sendPort.send(receivePort.sendPort);

      var lastKeepSeatTime = DateTime.now();

      while (running) {
        var currentTime = DateTime.now();

        // 60 seconds interval
        if (lastKeepSeatTime.add(options.keepSeatInterval).isBefore(currentTime)) {
          sendPort.send('keepSeat');
          lastKeepSeatTime = currentTime;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      receivePort.close();
    }, KeepSeatIsolateOptions(
      sendPort: keepSeatTimingReceivePort.sendPort,
      keepSeatInterval: keepSeatInterval,
    ));
  }

  Future<void> stop() async {
    // stop empty pings
    keepSeatTimingSendPort?.send('close');
    // keepSeatTimingIsolate?.kill(priority: Isolate.immediate);
    keepSeatTimingReceivePort?.close();

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
