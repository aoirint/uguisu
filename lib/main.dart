import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uguisu/niconico_live/niconico_live.dart';
import 'package:url_launcher/url_launcher_string.dart';

final mainLogger = Logger('main');

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  final loginCookie = await loadLoginCookie(file: await getLoginCookiePath());
  runApp(MyApp(initialLoginCookie: loginCookie));
}

class MyApp extends StatelessWidget {
  final NiconicoLoginCookie? initialLoginCookie;

  const MyApp({
    super.key,
    this.initialLoginCookie,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NiconicoLoginCookieData(loginCookie: initialLoginCookie),
        ),
      ],
      child: MaterialApp(
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
        routes: <String, WidgetBuilder>{
          '/': (_) => const NiconicoLivePageWidget(title: 'Uguisu Home'),
          '/login': (_) => const NiconicoLoginWidget(),
        },
      ),
    );
  }
}

Future<File> getLoginCookiePath() async {
  final appSupportDir = await getApplicationSupportDirectory();
  return File(path.join(appSupportDir.path, 'login_cookie.json'));
}

Future<NiconicoLoginCookie?> loadLoginCookie({
  required File file,
}) async {
  if (! file.existsSync()) {
    return null;
  }

  final rawJson = await file.readAsString(encoding: utf8);
  final json = jsonDecode(rawJson);

  if (json['version'] != '1') {
    mainLogger.warning('Unsupported cookies json version. Ignore this: ${file.path}');
    return null;
  }

  final cookiesText = json['cookies'];
  final dummyResponse = Response.bytes(
    [],
    200,
    headers: {'set-cookie': cookiesText},
  );
  final cookieJar = SweetCookieJar.from(response: dummyResponse);

  final userId = json['userId'];

  return NiconicoLoginCookie(
    cookieJar: cookieJar,
    userId: userId,
  );
}

Future<void> saveLoginCookie({
  required NiconicoLoginCookie loginCookie,
  required File file,
}) async {
  final cookiesText = loginCookie.cookieJar.rawData;
  final userId = loginCookie.userId;

  final rawJson = jsonEncode({
    'version': '1',
    'cookies': cookiesText,
    'userId': userId,
  });

  await file.writeAsString(rawJson, encoding: utf8);
}

class NiconicoLoginCookie {
  final SweetCookieJar cookieJar;
  final String userId;

  NiconicoLoginCookie({
    required this.cookieJar,
    required this.userId,
  });
}

class NiconicoLoginCookieData with ChangeNotifier {
  NiconicoLoginCookie? loginCookie;

  NiconicoLoginCookieData({this.loginCookie});

  void setLoginCookie({NiconicoLoginCookie? loginCookie}) {
    this.loginCookie = loginCookie;
    notifyListeners();
  }
}

class NiconicoLoginResultData with ChangeNotifier {
  NiconicoLoginResult? loginResult;

  void setLoginResult(NiconicoLoginResult? loginResult) {
    this.loginResult = loginResult;
    notifyListeners();
  }
}

class NiconicoMfaLoginResultData with ChangeNotifier {
  NiconicoMfaLoginResult? mfaLoginResult;

  void setMfaLoginResult(NiconicoMfaLoginResult? mfaLoginResult) {
    this.mfaLoginResult = mfaLoginResult;
    notifyListeners();
  }
}

class NiconicoLoginWidget extends StatelessWidget {
  const NiconicoLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NiconicoLoginResultData()),
        ChangeNotifierProvider(create: (context) => NiconicoMfaLoginResultData()),
      ],
      child: const NiconicoLoginSwitchWidget(),
    );
  }
}

class NiconicoLoginSwitchWidget extends StatelessWidget {
  const NiconicoLoginSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loginResult = context.watch<NiconicoLoginResultData>().loginResult;
    final mfaLoginResult = context.watch<NiconicoMfaLoginResultData>().mfaLoginResult;

    if (loginResult == null) {
      return const NiconicoNormalLoginWidget();
    }

    if (mfaLoginResult == null) {
      return const NiconicoMfaLoginWidget();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });

    return Column();
  }
}

class NiconicoNormalLoginWidget extends StatefulWidget {
  const NiconicoNormalLoginWidget({super.key});

  @override
  State<NiconicoNormalLoginWidget> createState() => _NiconicoNormalLoginWidgetState();
}

class _NiconicoNormalLoginWidgetState extends State<NiconicoNormalLoginWidget> {
  final mailTelTextController = TextEditingController(text: '');
  final passwordTextController = TextEditingController(text: '');

  Logger? logger;

  @override
  void initState() {
    super.initState();

    final logger = Logger('_NiconicoNormalLoginWidgetState');
    this.logger = logger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('ニコニコ動画アカウントにログイン', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: mailTelTextController,
                style: const TextStyle(fontSize: 12.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'メールアドレスまたは電話番号',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: passwordTextController,
                style: const TextStyle(fontSize: 12.0),
                enabled: true,
                maxLines: 1,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'パスワード',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('キャンセル', style: TextStyle(fontSize: 16.0)),
                    ),
                    onPressed: () async {
                      mailTelTextController.clear();
                      passwordTextController.clear();

                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('ログイン', style: TextStyle(fontSize: 16.0)),
                    ),
                    onPressed: () async {
                      const userAgent = 'uguisu/0.0.0';
                      final mailTel = mailTelTextController.text;
                      final password = passwordTextController.text;

                      final loginResult = await NiconicoLoginClient().login(
                        uri: Uri.parse('https://account.nicovideo.jp/login/redirector?site=niconico&next_url=%2F'), // site, next_url is required for user-id fetching; redirected to https://www.nicovideo.jp/ after MFA
                        mailTel: mailTel,
                        password: password,
                        userAgent: userAgent,
                      );

                      if (mounted) {
                        context.read<NiconicoLoginResultData>().setLoginResult(loginResult);

                        if (! loginResult.mfaRequired) {
                          final loginCookie = NiconicoLoginCookie(cookieJar: loginResult.cookieJar, userId: loginResult.userId!);
                          context.read<NiconicoLoginCookieData>().setLoginCookie(loginCookie: loginCookie);
                          await saveLoginCookie(loginCookie: loginCookie, file: await getLoginCookiePath());
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NiconicoMfaLoginWidget extends StatefulWidget {
  const NiconicoMfaLoginWidget({
    super.key,
  });

  @override
  State<NiconicoMfaLoginWidget> createState() => _NiconicoMfaLoginWidgetState();
}

class _NiconicoMfaLoginWidgetState extends State<NiconicoMfaLoginWidget> {
  final otpTextController = TextEditingController(text: '');
  final deviceNameTextController = TextEditingController(text: 'Uguisu');

  Logger? logger;

  @override
  void initState() {
    super.initState();

    final logger = Logger('main');
    this.logger = logger;
  }

  @override
  Widget build(BuildContext context) {
    final loginResult = context.watch<NiconicoLoginResultData>().loginResult;

    return Scaffold(
      body: loginResult == null ? Column() : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('確認コードの入力', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: otpTextController,
                style: const TextStyle(fontSize: 12.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: '確認コード',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: deviceNameTextController,
                style: const TextStyle(fontSize: 12.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'デバイス名',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('キャンセル', style: TextStyle(fontSize: 16.0)),
                    ),
                    onPressed: () {
                      otpTextController.clear();
                      deviceNameTextController.clear();

                      context.read<NiconicoLoginResultData>().setLoginResult(null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('ログイン', style: TextStyle(fontSize: 16.0)),
                    ),
                    onPressed: () async {
                      const userAgent = 'uguisu/0.0.0';
                      final otp = otpTextController.text;
                      final deviceName = deviceNameTextController.text;

                      final mfaLoginResult = await NiconicoLoginClient().mfaLogin(
                        mfaFormActionUri: loginResult.mfaFormActionUri!,
                        cookieJar: loginResult.cookieJar,
                        otp: otp,
                        deviceName: deviceName,
                        isMfaTrustedDevice: true,
                        userAgent: userAgent,
                      );

                      otpTextController.clear();
                      deviceNameTextController.clear();

                      if (mounted) {
                        context.read<NiconicoMfaLoginResultData>().setMfaLoginResult(mfaLoginResult);

                        final loginCookie = NiconicoLoginCookie(cookieJar: mfaLoginResult.cookieJar, userId: mfaLoginResult.userId);
                        context.read<NiconicoLoginCookieData>().setLoginCookie(loginCookie: loginCookie);
                        await saveLoginCookie(loginCookie: loginCookie, file: await getLoginCookiePath());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NiconicoLivePageWidget extends StatefulWidget {
  const NiconicoLivePageWidget({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<NiconicoLivePageWidget> createState() => _NiconicoLivePageWidgetState();
}

class _NiconicoLivePageWidgetState extends State<NiconicoLivePageWidget> {
  String? livePageUrl;
  NiconicoLivePage? livePage;
  NiconicoUserPageCache? livePageSupplierUserPageCache;
  NiconicoUserIconCache? livePageSupplierUserIconCache;
  ScheduleMessage? scheduleMessage;
  StatisticsMessage? statisticsMessage;
  List<BaseChatMessage> chatMessages = [];

  NiconicoLiveSimpleClient? simpleClient;
  final liveIdOrUrlTextController = TextEditingController(text: '');

  Logger? logger;

  @override
  void initState() {
    super.initState();

    final logger = Logger('main');
    this.logger = logger;
  }

  String? __createLivePageUrl({
    required String livePageIdOrUrl,
  }) {
    String? livePageUrl;

    // Full URL
    if (livePageIdOrUrl.startsWith('http')) {
      livePageUrl = livePageIdOrUrl;
    }

    // Live ID (lv000000000)
    final liveIdMatch = RegExp(r'^(lv\d+)$').firstMatch(livePageIdOrUrl);
    if (liveIdMatch != null) {
      final liveId = liveIdMatch.group(1); // lv000000000
      livePageUrl = 'https://live.nicovideo.jp/watch/${liveId}';
    }

    return livePageUrl;
  }

  void setLivePageUrl({
    required String livePageUrl,
    SweetCookieJar? cookieJar,
  }) {
    this.livePageUrl = livePageUrl;

    const userAgent = 'uguisu/0.0.0';

    Future(() async {
      await this.simpleClient?.stop();
      setState(() {
        livePage = null;
        scheduleMessage = null;
        statisticsMessage = null;
        chatMessages.clear();
      });

      final simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);
      this.simpleClient = simpleClient;

      Future<Uri> getUserPageUri(int userId) async {
        if (livePageUrl.startsWith('https://live.nicovideo.jp/watch/')) {
          return Uri.parse('https://www.nicovideo.jp/user/$userId');
        }
        return Uri.parse('http://127.0.0.1:10083/user_page/$userId');
      }

      try {
        await simpleClient.connect(
          livePageUrl: livePageUrl,
          cookieJar: cookieJar,
          onScheduleMessage: (scheduleMessage) {
            setState(() {
              this.scheduleMessage = scheduleMessage;
            });
            logger?.info('Schedule | begin=${scheduleMessage.begin}, end=${scheduleMessage.end}');
          },
          onStatisticsMessage: (statisticsMessage) {
            setState(() {
              this.statisticsMessage = statisticsMessage;
            });
            logger?.info('Statistics | viewers=${statisticsMessage.viewers}, comments=${statisticsMessage.comments}, adPoints=${statisticsMessage.adPoints}, giftPoints=${statisticsMessage.giftPoints}');
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
            final appSupportDir = await getApplicationSupportDirectory();
            final userIconJsonFile = File(path.join(appSupportDir.path, 'cache/user_icon/$userId.json'));
            if (! await userIconJsonFile.exists()) {
              logger?.warning('Cache-miss for user/$userId. User icon json not exists');
              return null;
            }

            final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
            final userIconJson = jsonDecode(userIconRawJson);

            if (userIconJson['version'] != '1') {
              logger?.warning('Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
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
              logger?.warning('Unexpected cache-miss for user/$userId. User icon image not exists');
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

            final appSupportDir = await getApplicationSupportDirectory();
            final iconFile = File(path.join(appSupportDir.path, 'cache/user_icon/$userId$iconFileNameSuffix'));
            await iconFile.parent.create(recursive: true);
            await iconFile.writeAsBytes(userIcon.userIcon.iconBytes, flush: true);

            final userIconJsonFile = File(path.join(appSupportDir.path, 'cache/user_icon/$userId.json'));
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
            final appSupportDir = await getApplicationSupportDirectory();
            final userPageJsonFile = File(path.join(appSupportDir.path, 'cache/user_page/$userId.json'));
            if (! await userPageJsonFile.exists()) {
              logger?.warning('Cache-miss for user/$userId. User page json not exists');
              return null;
            }

            final userPageRawJson = await userPageJsonFile.readAsString(encoding: utf8);
            final userPageJson = jsonDecode(userPageRawJson);

            if (userPageJson['version'] != '1') {
              logger?.warning('Unsupported user page json version. Ignore this: ${userPageJsonFile.path}');
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

            final appSupportDir = await getApplicationSupportDirectory();
            final userPageJsonFile = File(path.join(appSupportDir.path, 'cache/user_page/$userId.json'));
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
        
        final liveUserId = int.parse(simpleClient.livePage!.program.supplier.programProviderId);
        final livePageSupplierUserPageCache = await simpleClient.userPageCacheClient!.loadOrFetchUserPage(userId: liveUserId, userPageUri: await getUserPageUri(liveUserId));
        final livePageSupplierUserIconCache = await simpleClient.userIconCacheClient!.loadOrFetchIcon(userId: liveUserId, iconUri: Uri.parse(livePageSupplierUserPageCache.userPage.iconUrl));

        setState(() {
          livePage = simpleClient.livePage;
          this.livePageSupplierUserPageCache = livePageSupplierUserPageCache;
          this.livePageSupplierUserIconCache = livePageSupplierUserIconCache;
        });
      } on NoWatchWebSocketUrlFoundException {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text('エラー：番組への接続に失敗しました'),
              content: const Text('番組が終了しているか、公開されていない場合に発生することがあります。\n番組が終了している場合、タイムシフト視聴可能なアカウントでログインすると解消する場合があります（未実装）。'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        );
      }
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
    final loginCookieData = context.watch<NiconicoLoginCookieData>();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0), 
                      child: TextField(
                        controller: liveIdOrUrlTextController,
                        style: const TextStyle(fontSize: 12.0),
                        enabled: true,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Niconico Live ID or URL (e.g. lv000000000, https://live.nicovideo.jp/watch/lv000000000)',
                          contentPadding: EdgeInsets.all(4.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0), 
                    child: ElevatedButton(
                      onPressed: () {
                        final livePageIdOrUrl = liveIdOrUrlTextController.text;
                        final livePageUrl = __createLivePageUrl(livePageIdOrUrl: livePageIdOrUrl);
                        if (livePageUrl == null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text('エラー：入力された番組IDまたはURLの形式は非対応です'),
                                content: const Text('形式が合っているか確認してください。'),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          return;
                        }

                        setLivePageUrl(livePageUrl: livePageUrl, cookieJar: loginCookieData.loginCookie!.cookieJar);
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          livePage == null ? Container() : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  width: 64.0,
                  height: 64.0,
                  child: FittedBox(child: livePageSupplierUserIconCache != null ? Image.memory(livePageSupplierUserIconCache!.userIcon.iconBytes) : const Icon(Icons.account_box)),
                  // child: FittedBox(child: Icon(Icons.account_box)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
                    child: Text(livePage!.program.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                        child: Text.rich(
                          TextSpan(
                            text: livePage!.program.supplier.name,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                            mouseCursor: SystemMouseCursors.click,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = 'https://www.nicovideo.jp/user/${livePage!.program.supplier.programProviderId}';
                                if (!await launchUrlString(url)) {
                                  throw Exception('Failed to open URL: $url');
                                }
                              },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                        child: Text.rich(
                          TextSpan(
                            text: livePage!.socialGroup.name,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                            mouseCursor: SystemMouseCursors.click,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = 'https://com.nicovideo.jp/community/${livePage!.socialGroup.id}';
                                if (!await launchUrlString(url)) {
                                  throw Exception('Failed to open URL: $url');
                                }
                              },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                        child: Text('開始 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(livePage!.program.beginTime * 1000, isUtc: true).toLocal())}')
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                      //   child: Text('終了 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(livePage!.program.endTime * 1000, isUtc: true).toLocal())}')
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
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
                      final userId = chatMessage.chatMessage.userId;
                      if (nickname != null) {
                        name = SelectableText.rich(
                          TextSpan(
                            text: nickname,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                            mouseCursor: SystemMouseCursors.click,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = 'https://www.nicovideo.jp/user/$userId';
                                if (!await launchUrlString(url)) {
                                  throw Exception('Failed to open URL: $url');
                                }
                              },
                          ),
                        );
                      } else {
                        name = SelectableText(userId);
                      }
                    }

                    final commentedAtDateTime = DateTime.fromMillisecondsSinceEpoch(chatMessage.chatMessage.date * 1000, isUtc: true).toLocal();
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
          ),
        ],
      ),
    );
  }
}
