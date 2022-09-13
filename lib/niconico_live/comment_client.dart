import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';

class PingIsolateOptions {
  SendPort sendPort;
  Duration pingInterval;

  PingIsolateOptions({required this.sendPort, required this.pingInterval});
}

class NiconicoLiveCommentClient {
  WebSocket? client;
  ReceivePort? pingTimingReceivePort;
  SendPort? pingTimingSendPort;
  Isolate? pingTimingIsolate;
  Duration pingInterval;
  late Logger logger;

  NiconicoLiveCommentClient({
    this.pingInterval = const Duration(seconds: 60),
  }) {
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
    pingTimingReceivePort.listen((message) {
      if (message is SendPort) {
        pingTimingSendPort = message; // save the send port to another isolate to notify close event
      }
      if (message == 'ping') {
        client.add(''); // send a ping as an empty packet
      }
    });

    this.pingTimingReceivePort = pingTimingReceivePort;

    pingTimingIsolate = await Isolate.spawn((options) async {
      final sendPort = options.sendPort;
      var running = true;

      final receivePort = ReceivePort();
      receivePort.listen((message) {
        if (message == 'close') {
          running = false;
        }
      });

      sendPort.send(receivePort.sendPort);

      var lastPingTime = DateTime.now();

      while (running) {
        var currentTime = DateTime.now();

        // 60 seconds interval
        if (lastPingTime.add(options.pingInterval).isBefore(currentTime)) {
          sendPort.send('ping');
          lastPingTime = currentTime;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      receivePort.close();
    }, PingIsolateOptions(
      sendPort: pingTimingReceivePort.sendPort,
      pingInterval: pingInterval,
    ));
  }

  Future<void> stop() async {
    // stop empty pings
    pingTimingSendPort?.send('close');
    // pingTimingIsolate?.kill(priority: Isolate.immediate);
    pingTimingReceivePort?.close();

    logger.info('close websocket client');
    await client?.close();
    logger.info('closed');
  }

  void __handle(dynamic rawMessage) {
    logger.info('message: $rawMessage');
  }
}
