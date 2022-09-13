import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';

class KeepSeatIsolateOptions {
  SendPort sendPort;
  Duration keepSeatInterval;

  KeepSeatIsolateOptions({required this.sendPort, required this.keepSeatInterval});
}

class RoomMessageMessageServer {
  String type;
  String uri;

  RoomMessageMessageServer({
    required this.type,
    required this.uri,
  });
}

class RoomMessage {
  bool isFirst;
  RoomMessageMessageServer messageServer;
  String name;
  String threadId;
  String vposBaseTime;
  String waybackkey;
  String yourPostKey;

  RoomMessage({
    required this.isFirst,
    required this.messageServer,
    required this.name,
    required this.threadId,
    required this.vposBaseTime,
    required this.waybackkey,
    required this.yourPostKey,
  });
}

class NiconicoLiveWatchClient {
  WebSocket? client;
  Function(RoomMessage roomMessage)? onRoomMessage;
  ReceivePort? keepSeatTimingReceivePort;
  SendPort? keepSeatTimingSendPort;
  Isolate? keepSeatTimingIsolate;
  Duration keepSeatInterval;
  late Logger logger;

  NiconicoLiveWatchClient({
    this.keepSeatInterval = const Duration(seconds: 60),
  }) {
    logger = Logger('NiconicoLiveWatchClient');
  }

  Future<void> connect({
    required String websocketUrl,
    required Function(RoomMessage roomMessage) onRoomMessage,
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

    this.onRoomMessage = onRoomMessage;
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
      final Map<String, dynamic> messageServer = data['messageServer'];

      onRoomMessage?.call(RoomMessage(
        isFirst: data['isFirst'],
        messageServer: RoomMessageMessageServer(
          type: messageServer['type'],
          uri: messageServer['uri'],
        ),
        name: data['name'],
        threadId: data['threadId'],
        vposBaseTime: data['vposBaseTime'],
        waybackkey: data['waybackkey'],
        yourPostKey: data['yourPostKey'],
      ));
    }
  }
}
