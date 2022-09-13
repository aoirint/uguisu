import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';

Future<void> __startCommentClient({
  required String commentServerWebSocketUrl,
  required String userAgent,
  required String thread,
  String? threadkey,
  required Function(ChatMessage) onChatMessage,
}) async {
  final commentClient = NiconicoLiveCommentClient();
  try {
    await commentClient.connect(
      websocketUrl: commentServerWebSocketUrl,
      userAgent: userAgent,
      thread: thread,
      threadkey: threadkey,
      onChatMessage: onChatMessage,
    );

    await Future.delayed(const Duration(seconds: 3));
  } finally {
    await commentClient.stop();
  }
}

Future<void> main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('main');

  if (args.isEmpty) {
    throw Exception('Usage: dart run lib/niconico_live.dart livePageUrl');
  }
  final livePageUrl = args[0];
  logger.info('Live Page URL: $livePageUrl');

  const userAgent = 'uguisu/0.0.0';

  final simpleServer = NiconicoLiveSimpleServerEmulator();
  final simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);
  try {
    await simpleServer.start();
    try {
      var running = true;
      // var finishedAt = DateTime.now().add(const Duration(seconds: 120));

      // Akashic
      // ?: 放送者フォロー

      await simpleClient.connect(
        livePageUrl: livePageUrl, // for test: http://127.0.0.1:10080, for real case: https://live.nicovideo.jp/watch/lv000000000
        onScheduleMessage: (scheduleMessage) {
          logger.info('Schedule: begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          logger.info('Statistics: viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
          logger.info('Chat by user/${chatMessage.userId}: ${chatMessage.content}');
          final comment = chatMessage.content;

          if (chatMessage.premium == 2) { // 運営コメント
            if (comment == '/disconnect') { // 番組終了
              running = false;
            }
          }
          if (chatMessage.premium == 3) { // コマンド
            if (comment.startsWith('/emotion')) {
              // エモーション
              final emotionName = comment.substring(comment.indexOf(' ')+1).trim();
              logger.info('Emotion $emotionName');
            }

            if (comment.startsWith('/info')) {
              // 3: 延長 | /info 3 30分延長しました
              // 8: ランキング | /info 8 第7位にランクインしました
              // 10: 来場者 | /info 10 「DUMMY」が好きな1人が来場しました
              // ?: 好きなものリスト追加
              final infoRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
              final infoArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(infoRawMessage)[0];
              final infoId = infoArgs[0];
              final infoMessage = infoArgs[1];
              logger.info('Info $infoId $infoMessage');
            }

            if (comment.startsWith('/spi')) {
              // 放送ネタ
              final spiRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
              final spiArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(spiRawMessage)[0];
              final spiMessage = spiArgs[0];

              logger.info('Spi $spiMessage');
            }

            if (comment.startsWith('/nicoad')) {
              // ニコニ広告
              final nicoAdRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
              final nicoAdMessage = jsonDecode(nicoAdRawMessage);

              final nicoAdVersion = nicoAdMessage['version'];
              if (nicoAdVersion != '1') {
                logger.warning('Unsupported /nicoad version: $nicoAdVersion');
              }

              final totalAdPoint = nicoAdMessage['totalAdPoint'];
              final message = nicoAdMessage['message'];

              logger.info('Nicoad version=$nicoAdVersion totalAdPoint=$totalAdPoint message=$message');
            }

            if (comment.startsWith('/gift')) {
              // ギフト
              // /gift ギフトID ユーザーID \"ユーザー名\" ギフトポイント \"\" \"ギフト名\" 匿名フラグ？
              final giftRawMessage = comment.substring(comment.indexOf(' ')+1).trim();
              final giftArgs = const CsvToListConverter(fieldDelimiter: ' ', shouldParseNumbers: false).convert(giftRawMessage)[0];

              final giftId = giftArgs[0];
              final userId = giftArgs[1];
              final userName = giftArgs[2];
              final giftPoint = giftArgs[3];
              final empty = giftArgs[4];
              final giftName = giftArgs[5];
              final anonimity = giftArgs[6];

              logger.info('Gift giftId=$giftId userId=$userId userName=$userName giftPoint=$giftPoint empty=$empty giftName=$giftName anonimity=$anonimity');
            }
          }
        },
      );

      while (running) {
        // if (finishedAt.isBefore(DateTime.now())) {
        //   running = false;
        //   break;
        // }
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } finally {
      await simpleClient.stop();
    }
  } finally {
    await simpleServer.stop();
  }

  logger.info('exit');
}
