import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uguisu/niconico_live/niconico_live.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uguisu',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lime,
      ),
      home: const NiconicoLivePageWidget(title: 'Uguisu Home', livePageUrl: 'http://127.0.0.1:10080/'),
    );
  }
}

class NiconicoLivePageWidget extends StatefulWidget {
  const NiconicoLivePageWidget({
    super.key,
    required this.title,
    required this.livePageUrl,
  });

  final String title;
  final String livePageUrl;

  @override
  State<NiconicoLivePageWidget> createState() => _NiconicoLivePageWidgetState();
}

class CommentRow {
}

class _NiconicoLivePageWidgetState extends State<NiconicoLivePageWidget> {
  NiconicoLivePage? livePage;
  ScheduleMessage? scheduleMessage;
  StatisticsMessage? statisticsMessage;
  List<BaseChatMessage> chatMessages = [];

  NiconicoLiveSimpleClient? simpleClient;
  Logger? logger;

  @override
  void initState() {
    super.initState();

    const userAgent = 'uguisu/0.0.0';
    final livePageUrl = widget.livePageUrl;

    final logger = Logger('main');
    this.logger = logger;

    final simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);
    this.simpleClient = simpleClient;

    Future<Uri> getUserPageUri(int userId) async {
      if (livePageUrl.startsWith('https://live.nicovideo.jp/watch/')) {
        return Uri.parse('https://www.nicovideo.jp/user/$userId');
      }
      return Uri.parse('http://127.0.0.1:10083/user_page/$userId');
    }

    Future(() async {
      await simpleClient.connect(
        livePageUrl: livePageUrl,
        onScheduleMessage: (scheduleMessage) {
          setState(() {
            this.scheduleMessage = scheduleMessage;
          });
          logger.info('Schedule | begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
        },
        onStatisticsMessage: (statisticsMessage) {
          setState(() {
            this.statisticsMessage = statisticsMessage;
          });
          logger.info('Statistics | viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
        },
        onChatMessage: (chatMessage) {
          Future(() async {
            var cm = chatMessage;

            if (chatMessage is LazyNormalChatMessage) {
              cm = await chatMessage.resolve();
            }

            setState(() {
              chatMessages.add(cm);
              chatMessages.sort((a, b) => a.chatMessage.no.compareTo(b.chatMessage.no));
            });
          });
        },
        userIconLoadCacheOrNull: (userId) async {
          final userIconJsonFile = File('cache/user_icon/$userId.json');
          if (! await userIconJsonFile.exists()) {
            logger.warning('Cache-miss for user/$userId. User icon json not exists');
            return null;
          }

          final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
          final userIconJson = jsonDecode(userIconRawJson);

          if (userIconJson['version'] != '1') {
            logger.warning('Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
            return null;
          }

          final userIdInJson = userIconJson['userId'];
          if (userIdInJson != userId) {
            throw Exception('Invalid user icon json. userId does not match. given: $userId, json: $userIdInJson');
          }

          final iconUri = Uri.parse(userIconJson['iconUri']);
          final String contentType = userIconJson['contentType'];
          final iconUploadedAt = userIconJson['iconUploadedAt'] != null ? DateTime.parse(userIconJson['iconUploadedAt']) : null;
          final iconFetchedAt = DateTime.parse(userIconJson['iconFetchedAt']);
          final String iconPath = userIconJson['iconPath'];

          final iconFile = File(iconPath);
          if (! await iconFile.exists()) {
            logger.warning('Unexpected cache-miss for user/$userId. User icon image not exists');
            return null;
          }

          final iconBytes = await iconFile.readAsBytes();

          return NiconicoUserIconCache(
            userId: userId,
            userIcon: NiconicoUserIcon(
              iconUri: iconUri,
              contentType: contentType,
              iconBytes: iconBytes,
            ),
            iconUploadedAt: iconUploadedAt,
            iconFetchedAt: iconFetchedAt,
          );
        },
        userIconSaveCache: (userIcon) async {
          final userId = userIcon.userId;
          final contentType = userIcon.userIcon.contentType;

          String? iconFileNameSuffix;
          if (contentType == 'image/png') iconFileNameSuffix = '.png';
          if (contentType == 'image/jpeg') iconFileNameSuffix = '.jpg';
          if (contentType == 'image/gif') iconFileNameSuffix = '.gif';
          if (iconFileNameSuffix == null) {
            throw Exception('Unsupported content type: $contentType');
          }

          final iconFile = File('cache/user_icon/$userId$iconFileNameSuffix');
          await iconFile.parent.create(recursive: true);
          await iconFile.writeAsBytes(userIcon.userIcon.iconBytes, flush: true);

          final userIconJsonFile = File('cache/user_icon/$userId.json');
          final userIconRawJson = jsonEncode({
            'version': '1',
            'userId': userId,
            'iconUri': userIcon.userIcon.iconUri.toString(),
            'contentType': userIcon.userIcon.contentType,
            'iconUploadedAt': userIcon.iconUploadedAt?.toIso8601String(),
            'iconFetchedAt': userIcon.iconFetchedAt.toIso8601String(),
            'iconPath': iconFile.path,
          });

          await userIconJsonFile.writeAsString(userIconRawJson, encoding: utf8, flush: true);
        },
        getUserPageUri: getUserPageUri,
        userPageLoadCacheOrNull: (userId) async {
          final userPageJsonFile = File('cache/user_page/$userId.json');
          if (! await userPageJsonFile.exists()) {
            logger.warning('Cache-miss for user/$userId. User page json not exists');
            return null;
          }

          final userPageRawJson = await userPageJsonFile.readAsString(encoding: utf8);
          final userPageJson = jsonDecode(userPageRawJson);

          if (userPageJson['version'] != '1') {
            logger.warning('Unsupported user page json version. Ignore this: ${userPageJsonFile.path}');
            return null;
          }

          final userIdInJson = userPageJson['userId'];
          if (userIdInJson != userId) {
            throw Exception('Invalid user page json. userId does not match. given: $userId, json: $userIdInJson');
          }

          final nickname = userPageJson['nickname'];
          final iconUrl = userPageJson['iconUrl'];
          final pageFetchedAt = DateTime.parse(userPageJson['pageFetchedAt']);

          return NiconicoUserPageCache(
            userId: userId,
            userPage: NiconicoUserPage(
              id: userId,
              nickname: nickname,
              iconUrl: iconUrl,
            ),
            pageFetchedAt: pageFetchedAt,
          );
        },
        userPageSaveCache: (userPage) async {
          final userId = userPage.userId;

          final userPageJsonFile = File('cache/user_page/$userId.json');
          await userPageJsonFile.parent.create(recursive: true);
          final userPageRawJson = jsonEncode({
            'version': '1',
            'userId': userId,
            'nickname': userPage.userPage.nickname,
            'iconUrl': userPage.userPage.iconUrl,
            'pageFetchedAt': userPage.pageFetchedAt.toIso8601String(),
          });

          await userPageJsonFile.writeAsString(userPageRawJson, encoding: utf8, flush: true);
        },
      );
    });

    setState(() {
      livePage = simpleClient.livePage;
    });
  }

  @override
  void dispose() {
    super.dispose();

    Future(() async {
      await simpleClient?.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child: Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(), // no
                  1: FixedColumnWidth(32), // icon
                  2: IntrinsicColumnWidth(), // name
                  3: IntrinsicColumnWidth(), // time
                  4: FlexColumnWidth(), // content
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: chatMessages.map((chatMessage) {
                  Widget icon = Container();
                  if (chatMessage is NormalChatMessage) {
                    final iconBytes = chatMessage.commentUser?.userIconCache?.userIcon.iconBytes;
                    if (iconBytes != null) {
                      icon = Image.memory(iconBytes);
                    }
                  }

                  Widget name = Container();
                  if (chatMessage is NormalChatMessage) {
                    final nickname = chatMessage.commentUser?.userPageCache?.userPage.nickname;
                    if (nickname != null) {
                      name = SelectableText(nickname);
                    }
                  }

                  final commentedAtDateTime = DateTime.fromMillisecondsSinceEpoch(chatMessage.chatMessage.date * 1000, isUtc: true);
                  final dateFormat = DateFormat('HH:mm:ss');
                  final commentedAt = SelectableText(dateFormat.format(commentedAtDateTime));

                  TextStyle? textStyle;
                  if (chatMessage is! NormalChatMessage) {
                    // 0x727272
                    // 0xFF0033
                    textStyle = const TextStyle(color: Color.fromARGB(255, 0xFF, 0x00, 0x33));
                  }
                  final content = SelectableText(
                    chatMessage.chatMessage.content,
                    style: textStyle,
                  );

                  return TableRow(
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.all(8.0), child: SelectableText('${chatMessage.chatMessage.no}')),
                      icon,
                      Padding(padding: const EdgeInsets.all(8.0), child: name),
                      Padding(padding: const EdgeInsets.all(8.0), child: commentedAt),
                      Padding(padding: const EdgeInsets.all(8.0), child: content),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          logger?.info('Tapped plus');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
