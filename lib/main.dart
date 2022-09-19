import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:logging/logging.dart' as logging;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:uguisu/api/niconico/niconico.dart';
import 'package:uguisu/widgets/config/config.dart';
import 'package:uguisu/widgets/niconico/niconico.dart';
import 'package:window_manager/window_manager.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';

final mainLogger = Logger('com.aoirint.uguisu');

NiconicoLiveSimpleClient? simpleClient;
SharedPreferences? sharedPreferences;

const windowOpacityDefaultValue = 1.0;
const alwaysOnTopDefaultValue = false;
const commentTimeFormatElapsedDefaultValue = false;

const commentTableNoWidthDefaultValue = 50.0;
const commentTableUserIconWidthDefaultValue = 35.0;
const commentTableUserNameWidthDefaultValue = 180.0;
const commentTableTimeWidthDefaultValue = 72.0;
const commentTableRowHeightDefaultValue = 37.0;

void main() async {
  logging.hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) { 
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();

  if (isDesktopEnvironment()) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(1600, 900),
      // center: true,
      // backgroundColor: Colors.transparent,
      // skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final initialLoginCookie = await loadLoginCookie(file: await getLoginCookiePath());
  await initSimpleClient(loginCookie: initialLoginCookie);

  final initialConfig = await loadConfigFromSharedPreferences();
  await applyAndSaveConfig(config: initialConfig);

  runApp(MyApp(initialLoginCookie: initialLoginCookie, initialConfig: initialConfig));
}

bool isDesktopEnvironment() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

Future<Config> loadConfigFromSharedPreferences() async {
  final windowOpacity = sharedPreferences!.getDouble('windowOpacity') ?? windowOpacityDefaultValue;
  final alwaysOnTop = sharedPreferences!.getBool('alwaysOnTop') ?? alwaysOnTopDefaultValue;
  final commentTimeFormatElapsed = sharedPreferences!.getBool('commentTimeFormatElapsed') ?? commentTimeFormatElapsedDefaultValue;

  return Config(
    windowOpacity: windowOpacity,
    alwaysOnTop: alwaysOnTop,
    commentTimeFormatElapsed: commentTimeFormatElapsed,
  );
}

Future<void> applyAndSaveConfig({required Config config}) async {
  sharedPreferences!.setDouble('windowOpacity', config.windowOpacity);
  sharedPreferences!.setBool('alwaysOnTop', config.alwaysOnTop);

  if (isDesktopEnvironment()) {
    windowManager.setOpacity(config.windowOpacity);
    windowManager.setAlwaysOnTop(config.alwaysOnTop);
  }

  sharedPreferences!.setBool('commentTimeFormatElapsed', config.commentTimeFormatElapsed);
}

Future<String?> getUserIconPath(int userId) async {
  final appSupportDir = await getApplicationSupportDirectory();
  final userIconJsonFile = File(path.join(appSupportDir.path, 'cache/user_icon/$userId.json'));
  if (! await userIconJsonFile.exists()) {
    mainLogger.warning('Cache-miss for user/$userId. User icon json not exists');
    return null;
  }

  final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
  final userIconJson = jsonDecode(userIconRawJson);

  if (userIconJson['version'] != '1') {
    mainLogger.warning('Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
    return null;
  }

  final userIdInJson = userIconJson['userId'];
  if (userIdInJson != userId) {
    throw Exception('Invalid user icon json. userId does not match. given: $userId, json: $userIdInJson');
  }

  final String iconPath = userIconJson['iconPath'];
  return iconPath;
}

Future<NiconicoUserIconCache?> loadUserIconCache(int userId) async {
  final appSupportDir = await getApplicationSupportDirectory();
  final userIconJsonFile = File(path.join(appSupportDir.path, 'cache/user_icon/$userId.json'));
  if (! await userIconJsonFile.exists()) {
    mainLogger.warning('Cache-miss for user/$userId. User icon json not exists');
    return null;
  }

  final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
  final userIconJson = jsonDecode(userIconRawJson);

  if (userIconJson['version'] != '1') {
    mainLogger.warning('Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
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
    mainLogger.warning('Unexpected cache-miss for user/$userId. User icon image not exists');
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
}

Future<void> saveUserIconCache(NiconicoUserIconCache userIcon) async {
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
}

Future<void> initSimpleClient({
  NiconicoLoginCookie? loginCookie,
}) async {
  const userAgent = 'uguisu/0.0.0';

  simpleClient = NiconicoLiveSimpleClient(userAgent: userAgent);

  Future<Uri> getUserPageUri(int userId) async {
    // TODO: use local emulation server if not live.nicovideo.jp
    return Uri.parse('https://www.nicovideo.jp/user/$userId');
    // if (livePageUrl.startsWith('https://live.nicovideo.jp/watch/')) {
    //   return Uri.parse('https://www.nicovideo.jp/user/$userId');
    // }
    // return Uri.parse('http://127.0.0.1:10083/user_page/$userId');
  }

  await simpleClient!.initialize(
    loginCookie: loginCookie,
    userIconLoadCacheOrNull: loadUserIconCache,
    userIconSaveCache: saveUserIconCache,
    getUserPageUri: getUserPageUri,
    userPageLoadCacheOrNull: (userId) async {
      final appSupportDir = await getApplicationSupportDirectory();
      final userPageJsonFile = File(path.join(appSupportDir.path, 'cache/user_page/$userId.json'));
      if (! await userPageJsonFile.exists()) {
        mainLogger.warning('Cache-miss for user/$userId. User page json not exists');
        return null;
      }

      final userPageRawJson = await userPageJsonFile.readAsString(encoding: utf8);
      final userPageJson = jsonDecode(userPageRawJson);

      if (userPageJson['version'] != '1') {
        mainLogger.warning('Unsupported user page json version. Ignore this: ${userPageJsonFile.path}');
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
}

// Live Page
Future<File> getLivePageCachePath({
  required String communityId,
  required String liveId,
}) async {
  final appSupportDir = await getApplicationSupportDirectory();
  return File(path.join(appSupportDir.path, 'cache', 'live_page', communityId, '$liveId.json'));
}

Future<NiconicoLivePage?> loadLivePage({
  required File file,
}) async {
  if (! file.existsSync()) {
    return null;
  }

  final rawJson = await file.readAsString(encoding: utf8);
  final json = jsonDecode(rawJson);

  if (json['version'] != '1') {
    mainLogger.warning('Unsupported live page cache json version. Ignore this: ${file.path}');
    return null;
  }

  final webSocketUrl = json['webSocketUrl'];

  final program = json['program'];
  final programTitle = program['title'];
  final programNicoliveProgramId = program['nicoliveProgramId'];
  final programProviderType = program['providerType'];
  final programVisualProviderType = program['visualProviderType'];

  final programSupplier = program['supplier'];
  final programSupplierName = programSupplier['name'];
  final programSupplierProgramProviderId = programSupplier['programProviderId'];

  final programBeginTime = program['beginTime'];
  final programEndTime = program['endTime'];

  final socialGroup = json['socialGroup'];
  final socialGroupId = socialGroup['id'];
  final socialGroupName = socialGroup['name'];

  return NiconicoLivePage(
    webSocketUrl: webSocketUrl,
    program: NiconicoLivePageProgram(
      title: programTitle,
      nicoliveProgramId: programNicoliveProgramId,
      providerType: programProviderType,
      visualProviderType: programVisualProviderType,
      supplier: NiconicoLivePageProgramSupplier(
        name: programSupplierName,
        programProviderId: programSupplierProgramProviderId,
      ),
      beginTime: programBeginTime,
      endTime: programEndTime,
    ),
    socialGroup: NiconicoLivePageSocialGroup(
      id: socialGroupId,
      name: socialGroupName,
    ),
  );
}

Future<void> saveLivePage({
  required NiconicoLivePage livePage,
  required File file,
}) async {
  final rawJson = jsonEncode({
    'version': '1',
    'webSocketUrl': livePage.webSocketUrl,
    'program': {
      'title': livePage.program.title,
      'supplier': {
        'name': livePage.program.supplier.name,
        'programProviderId': livePage.program.supplier.programProviderId,
      },
      'beginTime': livePage.program.beginTime,
      'endTime': livePage.program.endTime,
    },
    'socialGroup': {
      'id': livePage.socialGroup.id,
      'name': livePage.socialGroup.name,
    },
  });

  await file.parent.create(recursive: true);
  await file.writeAsString(rawJson, encoding: utf8, flush: true);
}

// Live Comment
class NiconicoLiveRoom {
  final String name;
  final String thread;
  final chatMessages = <ChatMessage>[];

  NiconicoLiveRoom({
    required this.name,
    required this.thread,
  });
}

class NiconicoLiveComment {
  final String communityId;
  final String liveId;
  final List<NiconicoLiveRoom> rooms;

  NiconicoLiveComment({
    required this.communityId,
    required this.liveId,
    required this.rooms,
  });
}

Future<File> getLiveCommentCachePath({
  required String communityId,
  required String liveId,
}) async {
  final appSupportDir = await getApplicationSupportDirectory();
  return File(path.join(appSupportDir.path, 'cache', 'live_comment', communityId, '$liveId.json'));
}

Future<NiconicoLiveComment?> loadLiveComment({
  required File file,
}) async {
  if (! file.existsSync()) {
    return null;
  }

  final rawJson = await file.readAsString(encoding: utf8);
  final json = jsonDecode(rawJson);

  if (json['version'] != '1') {
    mainLogger.warning('Unsupported live comment cache json version. Ignore this: ${file.path}');
    return null;
  }

  final communityId = json['communityId'];
  final liveId = json['liveId'];

  final rawRooms = json['rooms'];
  final rooms = <NiconicoLiveRoom>[];
  for (final room in rawRooms) {
    final roomName = room['name'];
    final thread = room['thread'];
    final rawChatMessages = room['chatMessages'];
    final chatMessages = <ChatMessage>[];
    for (final chatMessage in rawChatMessages) {
      chatMessages.add(
        ChatMessage(
          anonymity: chatMessage['anonymity'],
          content: chatMessage['content'],
          date: chatMessage['date'],
          dateUsec: chatMessage['dateUsec'],
          no: chatMessage['no'],
          premium: chatMessage['premium'],
          thread: chatMessage['thread'],
          mail: chatMessage['mail'],
          userId: chatMessage['userId'],
          vpos: chatMessage['vpos'],
        )
      );
    }

    rooms.add(
      NiconicoLiveRoom(
        name: roomName,
        thread: thread,
      )..chatMessages.addAll(chatMessages)
    );
  }

  return NiconicoLiveComment(
    communityId: communityId,
    liveId: liveId,
    rooms: rooms,
  );
}

Future<void> saveLiveComment({
  required NiconicoLiveComment liveComment,
  required File file,
}) async {
  final rooms = <Map<String, dynamic>>[];
  for (final room in liveComment.rooms) {
    final chatMessages = <Map<String, dynamic>>[];
    for (final chatMessage in room.chatMessages) {
      final rawChatMessage = {
        'content': chatMessage.content,
        'date': chatMessage.date,
        'dateUsec': chatMessage.dateUsec,
        'no': chatMessage.no,
        'thread': chatMessage.thread,
        'userId': chatMessage.userId,
        'vpos': chatMessage.vpos,
      };
      if (chatMessage.anonymity != null) rawChatMessage['anonymity'] = chatMessage.anonymity!;
      if (chatMessage.premium != null) rawChatMessage['premium'] = chatMessage.premium!;
      if (chatMessage.mail != null) rawChatMessage['mail'] = chatMessage.mail!;

      chatMessages.add(rawChatMessage);
    }
    rooms.add({
      'name': room.name,
      'thread': room.thread,
      'chatMessages': chatMessages,
    });
  }

  final rawJson = jsonEncode({
    'version': '1',
    'communityId': liveComment.communityId,
    'liveId': liveComment.liveId,
    'rooms': rooms,
  });

  await file.parent.create(recursive: true);
  await file.writeAsString(rawJson, encoding: utf8, flush: true);
}

class NiconicoLoginUser {
  final NiconicoUserPageCache loginUserPageCache;
  final NiconicoUserIconCache loginUserIconCache;

  NiconicoLoginUser({
    required this.loginUserPageCache,
    required this.loginUserIconCache,
  });
}

class NiconicoLoginUserData with ChangeNotifier {
  NiconicoLoginUser? loginUser;

  void setLoginUserData({
    NiconicoLoginUser? loginUser,
  }) {
    this.loginUser = loginUser;
    notifyListeners();
  }
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

class ConfigData with ChangeNotifier {
  Config config;

  ConfigData({required this.config});

  void setConfig({required Config config}) {
    this.config = config;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final NiconicoLoginCookie? initialLoginCookie;
  final Config initialConfig;

  const MyApp({
    super.key,
    this.initialLoginCookie,
    required this.initialConfig,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NiconicoLoginCookieData(loginCookie: initialLoginCookie)),
        ChangeNotifierProvider(create: (context) => NiconicoLoginUserData()),
        ChangeNotifierProvider(create: (context) => ConfigData(config: initialConfig)),
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
          '/config': (_) => const ConfigWidget(),
          '/config/login': (_) => const NiconicoLoginWidget(),
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

class SimpleNiconicoLoginResolver with NiconicoLoginResolver {
  @override
  Future<NiconicoLoginResult?> resolveLogin({required String mailTel, required String password}) async {
    const userAgent = 'uguisu/0.0.0';

    final loginResult = await NiconicoLoginClient().login(
      uri: Uri.parse('https://account.nicovideo.jp/login/redirector?site=niconico&next_url=%2F'), // site, next_url is required for user-id fetching; redirected to https://www.nicovideo.jp/ after MFA
      mailTel: mailTel,
      password: password,
      userAgent: userAgent,
    );

    return loginResult;
  }
}

class SimpleNiconicoMfaLoginResolver with NiconicoMfaLoginResolver {
  final NiconicoLoginResult loginResult;

  SimpleNiconicoMfaLoginResolver({
    required this.loginResult,
  });

  @override
  Future<NiconicoMfaLoginResult?> resolveMfaLogin({required String otp, required String deviceName}) async {
    const userAgent = 'uguisu/0.0.0';

    final mfaLoginResult = await NiconicoLoginClient().mfaLogin(
      mfaFormActionUri: loginResult.mfaFormActionUri!,
      cookieJar: loginResult.cookieJar,
      otp: otp,
      deviceName: deviceName,
      isMfaTrustedDevice: true,
      userAgent: userAgent,
    );

    return mfaLoginResult;
  }
}

class ConfigWidget extends StatelessWidget {
  const ConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCookie = context.watch<NiconicoLoginCookieData>().loginCookie;
    final loginUser = context.watch<NiconicoLoginUserData>().loginUser;
    final configData = context.watch<ConfigData>();

    return ConfigDialog(
      loginCookie: loginCookie,
      loginUser: loginUser,
      userPageUriResolver: SimpleNiconicoUserPageUriResolver(),
      config: configData.config,
      onChanged: ({required config}) async {
        await applyAndSaveConfig(config: config);

        configData.setConfig(config: config);
      },
    );
  }
}

class NiconicoLoginWidget extends StatelessWidget {
  const NiconicoLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NiconicoLoginSwitchDialog(
      loginResolver: SimpleNiconicoLoginResolver(),
      mfaLoginResolverBuilder: ({required loginResult}) => SimpleNiconicoMfaLoginResolver(loginResult: loginResult),
      onLoginResult: ({required loginResult}) async {
        final loginCookie = NiconicoLoginCookie(cookieJar: loginResult.cookieJar, userId: loginResult.userId!);
        context.read<NiconicoLoginCookieData>().setLoginCookie(loginCookie: loginCookie);
        await saveLoginCookie(loginCookie: loginCookie, file: await getLoginCookiePath());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.popUntil(context, ModalRoute.withName('/config'));
        });
      },
      onMfaLoginResult: ({required mfaLoginResult}) async {
        final loginCookie = NiconicoLoginCookie(cookieJar: mfaLoginResult.cookieJar, userId: mfaLoginResult.userId);
        context.read<NiconicoLoginCookieData>().setLoginCookie(loginCookie: loginCookie);
        await saveLoginCookie(loginCookie: loginCookie, file: await getLoginCookiePath());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.popUntil(context, ModalRoute.withName('/config'));
        });
      },
    );
  }
}

// 差分を抑えるための、現状の実装を流用した仮置きの定義。多少非効率なことを許容する
class SimpleNiconicoUserIconImageBytesResolver with NiconicoUserIconImageBytesResolver {
  @override
  Future<Uint8List>? resolveUserIconImageBytes({required int userId}) async {
    final userPage = await simpleClient!.userPageCacheClient!.loadOrFetchUserPage(userId: userId, userPageUri: Uri.parse('https://www.nicovideo.jp/user/$userId'));
    final userIcon = await simpleClient!.userIconCacheClient!.loadOrFetchIcon(userId: userId, iconUri: Uri.parse(userPage.userPage.iconUrl));

    return userIcon.userIcon.iconBytes;
  }
}

class SimpleNiconicoLocalCachedUserIconImageFileResolver with NiconicoLocalCachedUserIconImageFileResolver {
  @override
  Future<File?> resolveLocalCachedUserIconImageFile({required int userId}) async {
    final iconPath = await getUserIconPath(userId);
    return iconPath != null ? File(iconPath) : null;
  }
}

class SimpleNiconicoUserPageUriResolver with NiconicoUserPageUriResolver {
  @override
  Future<Uri?> resolveUserPageUri({required int userId}) async {
    return Uri.parse('https://www.nicovideo.jp/user/$userId');
  }
}

class SimpleNiconicoCommunityPageUriResolver with NiconicoCommunityPageUriResolver {
  @override
  Future<Uri?> resolveCommunityPageUri({required String communityId}) async {
    return Uri.parse('https://com.nicovideo.jp/community/$communityId');
  }
}

class SimpleNiconicoLivePageUriResolver with NiconicoLivePageUriResolver {
  @override
  Future<Uri?> resolveLivePageUri({required String liveIdOrUrl}) async {
    String? livePageUrl;

    // Full URL
    // if (livePageIdOrUrl.startsWith('http')) {
    if (liveIdOrUrl.startsWith('https://live.nicovideo.jp/')) { // casual blocking unknown urls
      livePageUrl = liveIdOrUrl;
    }

    // Live ID (lv000000000)
    final liveIdMatch = RegExp(r'^(lv\d+)$').firstMatch(liveIdOrUrl);
    if (liveIdMatch != null) {
      final liveId = liveIdMatch.group(1); // lv000000000
      livePageUrl = 'https://live.nicovideo.jp/watch/${liveId}';
    }

    return livePageUrl != null ? Uri.parse(livePageUrl) : null;
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

  bool fetchAllRunning = false;

  final liveIdOrUrlTextController = TextEditingController(text: '');
  final chatMessageListScrollController = ScrollController();

  Logger? logger;

  @override
  void initState() {
    super.initState();

    final logger = Logger('main');
    this.logger = logger;
  }

  Future<void> addAllChatMessagesIfNotExists({
    required Iterable<BaseChatMessage> chatMessages,
  }) async {
    final nextChatMessages = this.chatMessages;

    for (final chatMessage in chatMessages) {
      final found = this.chatMessages.any((other) =>
        chatMessage.chatMessage.thread == other.chatMessage.thread && 
        chatMessage.chatMessage.no == other.chatMessage.no
      );
      if (found) continue;

      nextChatMessages.add(chatMessage);
    }

    nextChatMessages.sort((a, b) => a.chatMessage.no.compareTo(b.chatMessage.no));

    // ListViewの個数が変わる前にatBottomを検査
    final isScrollEnd = chatMessageListScrollController.position.atEdge && chatMessageListScrollController.position.pixels != 0;

    setState(() {
      this.chatMessages = nextChatMessages;
    });

    // ListViewの個数が変わってから末尾までスクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isScrollEnd) {
        chatMessageListScrollController.jumpTo(chatMessageListScrollController.position.maxScrollExtent);
      }
    });

    final rooms = <NiconicoLiveRoom>[];
    for (final chatMessage in nextChatMessages) {
      var room = rooms.firstWhereOrNull((room) => room.thread == chatMessage.chatMessage.thread);
      if (room == null) {
        final rawRoom = simpleClient!.rooms.firstWhere((other) => other.roomMessage.threadId == chatMessage.chatMessage.thread);
        room = NiconicoLiveRoom(name: rawRoom.roomMessage.name, thread: rawRoom.roomMessage.threadId);
        rooms.add(room);
      }

      room.chatMessages.add(chatMessage.chatMessage);
    }

    await saveLiveComment(
      liveComment: NiconicoLiveComment(
        communityId: livePage!.socialGroup.id,
        liveId: livePage!.program.nicoliveProgramId,
        rooms: rooms,
      ),
      file: await getLiveCommentCachePath(communityId: livePage!.socialGroup.id, liveId: livePage!.program.nicoliveProgramId)
    );
  }

  Future<void> addChatMessageIfNotExists({
    required BaseChatMessage chatMessage,
  }) async {
    await addAllChatMessagesIfNotExists(chatMessages: [chatMessage]);
  }

  void setLivePageUrl({
    required String livePageUrl,
    NiconicoLoginCookie? loginCookie,
  }) {
    this.livePageUrl = livePageUrl;

    Future(() async {
      await simpleClient?.disconnect();
      setState(() {
        livePage = null;
        scheduleMessage = null;
        statisticsMessage = null;
        chatMessages.clear();
      });

      try {
        await initSimpleClient(
          loginCookie: loginCookie,
        );
        await simpleClient!.connect(
          livePageUrl: livePageUrl,
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

              if (cm is LazyNormalChatMessage) {
                cm = await cm.resolve();
              }

              if (cm is DisconnectChatMessage) {
                logger?.info('Close websocket connection due to the disconnect chat message (No. ${cm.chatMessage.no})');
                simpleClient?.disconnect();
              }

              setState(() {
                addChatMessageIfNotExists(chatMessage: cm);
              });
            });
          },
          onRFrameClosed: (rvalue) {
            // On first frame fetched
            logger?.info('R frame $rvalue closed');

            if (rvalue == 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                chatMessageListScrollController.jumpTo(chatMessageListScrollController.position.maxScrollExtent);
              });
            }
          }
        );
        
        final liveUserId = int.parse(simpleClient!.livePage!.program.supplier.programProviderId);
        final livePageSupplierUserPageCache = await simpleClient!.userPageCacheClient!.loadOrFetchUserPage(userId: liveUserId, userPageUri: await simpleClient!.getUserPageUri!.call(liveUserId));
        final livePageSupplierUserIconCache = await simpleClient!.userIconCacheClient!.loadOrFetchIcon(userId: liveUserId, iconUri: Uri.parse(livePageSupplierUserPageCache.userPage.iconUrl));

        await saveLivePage(
          livePage: simpleClient!.livePage!,
          file: await getLivePageCachePath(
            communityId: simpleClient!.livePage!.socialGroup.id,
            liveId: simpleClient!.livePage!.program.nicoliveProgramId,
          ),
        );

        setState(() {
          livePage = simpleClient!.livePage;
          this.livePageSupplierUserPageCache = livePageSupplierUserPageCache;
          this.livePageSupplierUserIconCache = livePageSupplierUserIconCache;
        });

        // Load cached live comments for reconnecting
        // FIXME: reenable fetch-all button to fetch unfetched comments between the connections
        // final liveComment = await loadLiveComment(
        //   file: await getLiveCommentCachePath(
        //     communityId: simpleClient!.livePage!.socialGroup.id,
        //     liveId: simpleClient!.livePage!.program.nicoliveProgramId,
        //   ),
        // );
        // if (liveComment != null) {
        //   final chatMessages = <BaseChatMessage>[];
        //   for (final room in liveComment.rooms) {
        //     for (final chatMessage in room.chatMessages) {
        //       var cm = simpleClient!.parseChatMessage(chatMessage);
        //       if (cm is LazyNormalChatMessage) {
        //         cm = await cm.resolve();
        //       }
        //       chatMessages.add(cm);
        //     }
        //   }
        //   await addAllChatMessagesIfNotExists(chatMessages: chatMessages);
        // }
      } on NoWatchWebSocketUrlFoundException {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text('エラー：番組への接続に失敗しました'),
              content: const Text('番組が終了しているか、公開されていない場合に発生することがあります。\n番組が終了している場合、タイムシフト視聴可能なアカウントでログインすると解消する場合があります。\nタイムシフトが非公開または公開期間終了済みの場合、コメントを取得することはできません。'),
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
      await simpleClient?.disconnect();
    });
  }

  int? getMinCommentNo() {
    if (chatMessages.isEmpty) return null;

    final minNoChatMessage = chatMessages.reduce((cur, next) => cur.chatMessage.no < next.chatMessage.no ? cur : next);
    final minNo = minNoChatMessage.chatMessage.no;
    return minNo;
  }

  @override
  Widget build(BuildContext context) {
    final loginCookieData = context.watch<NiconicoLoginCookieData>();
    final loginUserData = context.watch<NiconicoLoginUserData>();
    final configData = context.watch<ConfigData>();

    Future(() async {
      if (loginCookieData.loginCookie == null) {
        if (loginUserData.loginUser != null) {
          loginUserData.setLoginUserData(loginUser: null);
        }
      } else {
        final userId = int.parse(loginCookieData.loginCookie!.userId);

        if (loginUserData.loginUser == null) {
          final loginUserPageCache = await simpleClient!.userPageCacheClient!.loadOrFetchUserPage(
            userId: userId,
            userPageUri: await simpleClient!.getUserPageUri!.call(userId),
          );

          final loginUserIconCache = await simpleClient!.userIconCacheClient!.loadOrFetchIcon(
            userId: userId,
            iconUri: Uri.parse(loginUserPageCache.userPage.iconUrl),
          );

          loginUserData.setLoginUserData(
            loginUser: NiconicoLoginUser(
              loginUserPageCache: loginUserPageCache,
              loginUserIconCache: loginUserIconCache,
            ),
          );
        }
      } 
    });

    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child: NiconicoLiveConnectForm(
                liveIdOrUrlTextController: liveIdOrUrlTextController,
                livePageUriResolver: SimpleNiconicoLivePageUriResolver(),
                onSubmitLivePageUri: ({required livePageUri}) async {
                  setLivePageUrl(livePageUrl: livePageUri.toString(), loginCookie: loginCookieData.loginCookie);
                },
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  message: '設定',
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/config');
                    },
                    child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.settings)),
                  ),
                ),
              ),
            ],
          ),
          livePage == null ? Container() : NiconicoLiveHeader(
            livePageUrl: livePageUrl!,
            liveId: livePage!.program.nicoliveProgramId,
            liveTitle: livePage!.program.title,
            liveBeginDateTime: DateTime.fromMillisecondsSinceEpoch(livePage!.program.beginTime * 1000, isUtc: true),
            userIconImageBytesResolver: SimpleNiconicoUserIconImageBytesResolver(),
            userLocalCachedIconImageFileResolver: SimpleNiconicoLocalCachedUserIconImageFileResolver(),
            userPageUriResolver: SimpleNiconicoUserPageUriResolver(),
            communityPageUriResolver: SimpleNiconicoCommunityPageUriResolver(),
            supplierUserId: int.parse(livePage!.program.supplier.programProviderId),
            supplierUserName: livePage!.program.supplier.name,
            supplierCommunityId: livePage!.socialGroup.id,
            supplierCommunityName: livePage!.socialGroup.name,
          ),
          livePage == null ? Expanded(child: Container()) : NiconicoLiveCommentList(
            chatMessageListScrollController: chatMessageListScrollController,
            liveBeginDateTime: DateTime.fromMillisecondsSinceEpoch(livePage!.program.beginTime * 1000, isUtc: true),
            chatMessages: chatMessages,
            userLocalCachedIconImageFileResolver: SimpleNiconicoLocalCachedUserIconImageFileResolver(),
            userPageUriResolver: SimpleNiconicoUserPageUriResolver(),
            commentTimeFormatElapsed: configData.config.commentTimeFormatElapsed,
            commentTableRowHeight: commentTableRowHeightDefaultValue,
            commentTableNoWidth: commentTableNoWidthDefaultValue,
            commentTableUserIconWidth: commentTableUserIconWidthDefaultValue,
            commentTableUserNameWidth: commentTableUserNameWidthDefaultValue,
            commentTableTimeWidth: commentTableTimeWidthDefaultValue,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: NiconicoLiveStatistics(
                viewers: statisticsMessage?.viewers,
                comments: statisticsMessage?.comments,
                adPoints: statisticsMessage?.adPoints,
                giftPoints: statisticsMessage?.giftPoints,
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  message: '未取得コメントをすべて取得',
                  child: ElevatedButton(
                    onPressed: livePage == null || loginCookieData.loginCookie == null || getMinCommentNo() == 1 || fetchAllRunning ? null : () async {
                      if (chatMessages.isEmpty) {
                        logger?.warning('No fetched chat messages');
                        return;
                      }

                      const userAgent = 'uguisu/0.0.0';
                      const windowSize = 200;

                      if (simpleClient!.rooms.isEmpty) {
                        logger?.warning('No room');
                        return;
                      }

                      setState(() {
                        fetchAllRunning = true;
                      });

                      final room = simpleClient!.rooms[0];

                      // final maxNoChatMessage = chatMessages.reduce((cur, next) => cur.chatMessage.no > next.chatMessage.no ? cur : next);
                      // final maxNo = maxNoChatMessage.chatMessage.no;

                      var minNoChatMessage = chatMessages.reduce((cur, next) => cur.chatMessage.no < next.chatMessage.no ? cur : next);
                      var minNo = minNoChatMessage.chatMessage.no;
                      var minWhen = DateTime.fromMicrosecondsSinceEpoch(minNoChatMessage.chatMessage.date * 1000 * 1000 + minNoChatMessage.chatMessage.dateUsec);

                      final windowNum = (minNo / windowSize).ceil();
                      // final windowHeadNoList = List<int>.generate(windowNum, (index) => minNo - windowSize * (index + 1));

                      final newChatMessages = <BaseChatMessage>[];
                      var rvalue = 0;
                      var pvalue = 0;
                      for (var windowIndex=0; windowIndex<windowNum; windowIndex+=1) {
                        logger?.info('Window $windowIndex/$windowNum (minNo: $minNo, minWhen: $minWhen)');

                        final thread = await NiconicoLiveCommentWaybackClient().fetchWaybackThread(
                          websocketUrl: room.roomMessage.messageServer.uri,
                          userAgent: userAgent,
                          thread: room.roomMessage.threadId,
                          resFrom: -windowSize,
                          userId: loginCookieData.loginCookie!.userId,
                          when: (minWhen.millisecondsSinceEpoch / 1000).floor(),
                          rvalue: rvalue,
                          pvalue: pvalue,
                        );

                        // TODO: commonize parse and resolve chat message
                        for (final chatMessage in thread.chatMessages) {
                          var cm = simpleClient!.parseChatMessage(chatMessage);

                          if (cm is LazyNormalChatMessage) {
                            cm = await cm.resolve();
                          }

                          newChatMessages.add(cm);
                        }

                        if (newChatMessages.isEmpty) {
                          logger?.info('No new chat message, break');
                          break;
                        }

                        minNoChatMessage = newChatMessages.reduce((cur, next) => cur.chatMessage.no < next.chatMessage.no ? cur : next);
                        minNo = minNoChatMessage.chatMessage.no;
                        minWhen = DateTime.fromMicrosecondsSinceEpoch(minNoChatMessage.chatMessage.date * 1000 * 1000 + minNoChatMessage.chatMessage.dateUsec);

                        rvalue += 1;
                        pvalue += 5;
                        await Future.delayed(const Duration(milliseconds: 100));
                      }

                      await addAllChatMessagesIfNotExists(chatMessages: newChatMessages);

                      setState(() {
                        fetchAllRunning = false;
                      });

                      // const firstNo = 1;
                      // const windowSize = 150;
                      // final windowNum = ((minNo - firstNo) / windowSize).ceil();
                      // final windowHeadNoList =List<int>.generate(windowNum, (index) => firstNo + windowSize * index);
                      // print(windowHeadNoList);
                    },
                    child: const Padding(padding: EdgeInsets.all(4.0), child: Text('すべて取得')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
