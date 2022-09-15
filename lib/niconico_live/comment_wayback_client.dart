import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/comment_client.dart';

class NiconicoLiveCommentWaybackThread {
  int? lastRes;
  int resultcode;
  int revision;
  int serverTime;
  String thread;
  String? ticket;

  NiconicoLiveCommentWaybackThread({
    required this.lastRes,
    required this.resultcode,
    required this.revision,
    required this.serverTime,
    required this.thread,
    required this.ticket,
  });
}

class NiconicoLiveCommentWaybackThreadResult {
  NiconicoLiveCommentWaybackThread thread;
  List<ChatMessage> chatMessages;

  NiconicoLiveCommentWaybackThreadResult({
    required this.thread,
    required this.chatMessages,
  });
}

class NiconicoLiveCommentWaybackClient {
  late Logger logger;

  NiconicoLiveCommentWaybackClient() {
    logger = Logger('NiconicoLiveCommentWaybackClient');
  }

  Future<NiconicoLiveCommentWaybackThreadResult> fetchWaybackThread({
    required String websocketUrl,
    required String userAgent,
    required String thread,
    String? threadkey,
    required int resFrom,
    String? userId,
    int? when,
    required int rvalue, // 0, 1, 2, ...
    required int pvalue, // 0, 5, 10, ...
  }) async {
    logger.info('connect to $websocketUrl');

    WebSocket client = await WebSocket.connect(websocketUrl, headers: {
      'User-Agent': userAgent,
    });
    try {
      NiconicoLiveCommentWaybackThread? waybackThread;
      final chatMessages = <ChatMessage>[];

      var running = true;

      client.listen(
        (rawMessage) {
          logger.info('message: $rawMessage');
          final Map<String, dynamic> message = jsonDecode(rawMessage);

          if (message.containsKey('ping')) {
            final Map<String, dynamic> ping = message['ping'];
            final content = ping['content'];

            if (content == 'rs:$rvalue') {
            }
            if (content == 'ps:$pvalue') {
            }

            if (content == 'pf:$pvalue') {
            }
            if (content == 'rf:$rvalue') {
              running = false;
            }
          }

          if (message.containsKey('thread')) {
            final Map<String, dynamic> thread = message['thread'];

            waybackThread = NiconicoLiveCommentWaybackThread(
              lastRes: thread['last_res'],
              resultcode: thread['resultcode'],
              revision: thread['revision'],
              serverTime: thread['server_time'],
              thread: thread['thread'],
              ticket: thread['ticket'],
            );
          }

          if (message.containsKey('chat')) {
            final Map<String, dynamic> chat = message['chat'];

            chatMessages.add(ChatMessage(
              anonymity: chat['anonymity'],
              content: chat['content'],
              date: chat['date'],
              dateUsec: chat['date_usec'],
              no: chat['no'],
              premium: chat['premium'],
              thread: chat['thread'],
              userId: chat['user_id'],
              vpos: chat['vpos'],
            ));
          }
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
        'res_from': resFrom,
        'scores': 1,
        'thread': thread,
        'user_id': userId ?? 'guest',
        'version': '20061206',
        'with_global': 1,
      };

      if (threadkey != null) {threadObj['threadkey'] = threadkey; }
      if (when != null) { threadObj['when'] = when; }

      client!.add(jsonEncode([
        { 'ping': { 'content': 'rs:$rvalue' } },
        { 'ping': { 'content': 'ps:$pvalue' } },
        { 'thread': threadObj },
        { 'ping': { 'content': 'pf:$pvalue' } },
        { 'ping': { 'content': 'rf:$rvalue' } },
      ]));

      while (running) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      if (waybackThread == null) {
        throw Exception('Thread not returned in thread frame');
      }

      return NiconicoLiveCommentWaybackThreadResult(
        thread: waybackThread!,
        chatMessages: chatMessages,
      );
    } finally {
      logger.info('close websocket client');
      client.close();
      logger.info('closed');
    }
  }

}
