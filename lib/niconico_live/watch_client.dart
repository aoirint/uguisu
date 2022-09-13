import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';

class KeepSeatIsolateOptions {
  SendPort sendPort;

  KeepSeatIsolateOptions({
    required this.sendPort,
  });
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
  String? yourPostKey;

  RoomMessage({
    required this.isFirst,
    required this.messageServer,
    required this.name,
    required this.threadId,
    required this.vposBaseTime,
    required this.waybackkey,
    this.yourPostKey,
  });
}

class ScheduleMessage {
  String begin;
  String end;

  ScheduleMessage({
    required this.begin,
    required this.end,
  });
}

class StatisticsMessage {
  int viewers;
  int comments;
  int adPoints;
  int giftPoints;

  StatisticsMessage({
    required this.viewers,
    required this.comments,
    required this.adPoints,
    required this.giftPoints,
  });
}

class NiconicoLiveWatchClient {
  WebSocket? client;
  Function(RoomMessage roomMessage)? onRoomMessage;
  Function(ScheduleMessage scheduleMessage)? onScheduleMessage;
  Function(StatisticsMessage statisticsMessage)? onStatisticsMessage;
  ReceivePort? keepSeatTimingReceivePort;
  SendPort? keepSeatTimingSendPort;
  Isolate? keepSeatTimingIsolate;
  late Logger logger;

  NiconicoLiveWatchClient() {
    logger = Logger('NiconicoLiveWatchClient');
  }

  Future<void> connect({
    required String websocketUrl,
    required String userAgent,
    required Function(RoomMessage roomMessage) onRoomMessage,
    required Function(ScheduleMessage scheduleMessage) onScheduleMessage,
    required Function(StatisticsMessage statisticsMessage) onStatisticsMessage,
  }) async {
    logger.info('connect to $websocketUrl');

    WebSocket client = await WebSocket.connect(websocketUrl, headers: {
      'User-Agent': userAgent,
    });
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
      if (message is Map) {
        if (message['type'] == 'log') {
          logger.info(message['data']['content']);
        }
      }
      if (message == 'keepSeat') {
        client.add(jsonEncode({ 'type': 'keepSeat' })); // send a ping as an empty packet
      }
    });

    this.keepSeatTimingReceivePort = keepSeatTimingReceivePort;

    keepSeatTimingIsolate = await Isolate.spawn((options) async {
      final logger = Logger('NiconicoLiveWatchClient[keepSeatTimingIsolate]');
      final sendPort = options.sendPort;

      var running = true;
      int keepIntervalSec = 30;

      final receivePort = ReceivePort();
      receivePort.listen((message) {
        if (message is Map) {
          if (message['type'] == 'set_keep_interval') {
            keepIntervalSec = message['data']['keepIntervalSec'];
            sendPort.send({
              'type': 'log',
              'data': {
                'content': 'set_keep_interval: $keepIntervalSec',
              },
            });
          }
        }
        if (message == 'close') {
          running = false;
        }
      });

      sendPort.send(receivePort.sendPort);

      var lastKeepSeatTime = DateTime.now();

      while (running) {
        var currentTime = DateTime.now();

        // 60 seconds interval
        if (lastKeepSeatTime.add(Duration(seconds: keepIntervalSec)).isBefore(currentTime)) {
          sendPort.send('keepSeat');
          lastKeepSeatTime = currentTime;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      receivePort.close();
    }, KeepSeatIsolateOptions(
      sendPort: keepSeatTimingReceivePort.sendPort,
    ));

    this.onRoomMessage = onRoomMessage;
    this.onScheduleMessage = onScheduleMessage;
    this.onStatisticsMessage = onStatisticsMessage;
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
    } else if (type == 'seat') {
      final data = message['data'];
      int keepIntervalSec = data['keepIntervalSec'];

      keepSeatTimingSendPort?.send({
        'type': 'set_keep_interval',
        'data': {
          'keepIntervalSec': keepIntervalSec,
        },
      });
    } else if (type == 'room') {
      final Map<String, dynamic> data = message['data'];
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
        yourPostKey: data.containsKey('yourPostKey') ? data['yourPostKey'] : null, // if not logined, undefined.
      ));
    } else if (type == 'schedule') {
      final data = message['data'];
      onScheduleMessage?.call(ScheduleMessage(
        begin: data['begin'],
        end: data['end'],
      ));
    } else if (type == 'statistics') {
      final data = message['data'];
      onStatisticsMessage?.call(StatisticsMessage(
        viewers: data['viewers'],
        comments: data['comments'],
        adPoints: data['adPoints'],
        giftPoints: data['giftPoints'],
      ));
    }
  }
}
