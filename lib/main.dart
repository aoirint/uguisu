import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:logging/logging.dart' as logging;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:pool/pool.dart';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:uguisu/api/niconico/niconico.dart';
import 'package:uguisu/database/uguisu_database.dart';
import 'package:uguisu/niconico_live/community_icon_cache_client.dart';
import 'package:uguisu/niconico_live/community_icon_client.dart';
import 'package:uguisu/niconico_live/community_page_cache_client.dart';
import 'package:uguisu/niconico_live/community_page_client.dart';
import 'package:uguisu/widgets/config/config.dart';
import 'package:uguisu/widgets/niconico/niconico.dart';
import 'package:window_manager/window_manager.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';

final mainLogger = Logger('com.aoirint.uguisu');

NiconicoLiveSimpleClient? simpleClient;
SharedPreferences? sharedPreferences;
UguisuDatabase? uguisuDatabase;

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
  uguisuDatabase = UguisuDatabase();

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

// User icon cache
Future<String?> getUserIconPath(int userId) async {
  final uguisuNicoliveUserIconCaches = uguisuDatabase!.uguisuNicoliveUserIconCaches;
  final uguisuNicoliveUsers = uguisuDatabase!.uguisuNicoliveUsers;

  final joinedResult = await (
    uguisuDatabase!.select(uguisuNicoliveUserIconCaches).join([
      innerJoin(
        uguisuNicoliveUsers,
        uguisuNicoliveUserIconCaches.user.equalsExp(uguisuNicoliveUsers.id),
      ),
    ])
      ..where(uguisuNicoliveUsers.serviceId.equals('nicolive') & uguisuNicoliveUsers.userId.equals(userId))
  ).getSingleOrNull();

  if (joinedResult == null) {
    mainLogger.info('getUserIconPath: Cache-miss for user_icon/$userId');
    return null;
  }

  final userIconCache = joinedResult.readTable(uguisuNicoliveUserIconCaches);
  return userIconCache.path;
}

Future<NiconicoUserIconCache?> loadUserIconCache(int userId) async {
  final uguisuNicoliveUserIconCaches = uguisuDatabase!.uguisuNicoliveUserIconCaches;
  final uguisuNicoliveUsers = uguisuDatabase!.uguisuNicoliveUsers;

  final joinedResult = await (
    uguisuDatabase!.select(uguisuNicoliveUserIconCaches).join([
      innerJoin(
        uguisuNicoliveUsers,
        uguisuNicoliveUserIconCaches.user.equalsExp(uguisuNicoliveUsers.id),
      ),
    ])
      ..where(uguisuNicoliveUsers.serviceId.equals('nicolive') & uguisuNicoliveUsers.userId.equals(userId))
  ).getSingleOrNull();

  if (joinedResult == null) {
    mainLogger.info('loadUserIconCache: Cache-miss for user_icon/$userId');
    return null;
  }

  mainLogger.fine('loadUserIconCache: Cache-hit for user_icon/$userId');

  final userIconCache = joinedResult.readTable(uguisuNicoliveUserIconCaches);
  final user = joinedResult.readTable(uguisuNicoliveUsers);

  final iconFile = File(userIconCache.path);
  if (! await iconFile.exists()) {
    mainLogger.warning('Unexpected cache-miss for user_icon/$userId. User icon image file not exists');
    return null;
  }

  final iconBytes = await iconFile.readAsBytes();

  return NiconicoUserIconCache(
    userId: userId,
    userIcon: NiconicoUserIcon(
      iconUri: Uri.parse(user.iconUrl),
      contentType: userIconCache.contentType,
      iconBytes: iconBytes,
    ),
    iconUploadedAt: userIconCache.uploadedAt,
    iconFetchedAt: userIconCache.fetchedAt,
  );
}

Future<void> saveUserIconCache(NiconicoUserIconCache userIcon) async {
  final uguisuNicoliveUserIconCaches = uguisuDatabase!.uguisuNicoliveUserIconCaches;
  final uguisuNicoliveUsers = uguisuDatabase!.uguisuNicoliveUsers;

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

  final userPageCache = await (uguisuDatabase!.select(uguisuNicoliveUsers)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  if (userPageCache == null) {
    throw Exception('User page cache not found for user/$userId');
  }

  final rowId = await uguisuDatabase!.into(uguisuNicoliveUserIconCaches).insert(
    UguisuNicoliveUserIconCachesCompanion.insert(
      user: userPageCache.id,
      contentType: userIcon.userIcon.contentType,
      path: iconFile.path,
      uploadedAt: Value(userIcon.iconUploadedAt),
      fetchedAt: userIcon.iconFetchedAt,
    ),
    onConflict: DoUpdate.withExcluded(
      (old, excluded) => UguisuNicoliveUserIconCachesCompanion.custom(
        contentType: excluded.contentType,
        path: excluded.path,
        uploadedAt: excluded.uploadedAt,
        fetchedAt: excluded.fetchedAt,
      ),
      target: [uguisuNicoliveUserIconCaches.user],
    ),
  );
  mainLogger.info('saveUserIconCache: user_icon/$userId cache saved (rowid=$rowId)');
}

// Community icon cache
Future<String?> getCommunityIconPath(String communityId) async {
  final uguisuNicoliveCommunityIconCaches = uguisuDatabase!.uguisuNicoliveCommunityIconCaches;
  final uguisuNicoliveCommunities = uguisuDatabase!.uguisuNicoliveCommunities;

  final joinedResult = await (
    uguisuDatabase!.select(uguisuNicoliveCommunities).join([
      innerJoin(
        uguisuNicoliveCommunities,
        uguisuNicoliveCommunityIconCaches.community.equalsExp(uguisuNicoliveCommunities.id),
      ),
    ])
      ..where(uguisuNicoliveCommunities.serviceId.equals('nicolive') & uguisuNicoliveCommunities.communityId.equals(communityId))
  ).getSingleOrNull();

  if (joinedResult == null) {
    mainLogger.info('getCommunityIconPath: Cache-miss for community_icon/$communityId');
    return null;
  }

  mainLogger.fine('getCommunityIconPath: Cache-hit for community_icon/$communityId');

  final communityIconCache = joinedResult.readTable(uguisuNicoliveCommunityIconCaches);
  return communityIconCache.path;
}

Future<NiconicoCommunityIconCache?> loadCommunityIconCache(String communityId) async {
  final uguisuNicoliveCommunityIconCaches = uguisuDatabase!.uguisuNicoliveCommunityIconCaches;
  final uguisuNicoliveCommunities = uguisuDatabase!.uguisuNicoliveCommunities;

  final joinedResult = await (
    uguisuDatabase!.select(uguisuNicoliveCommunityIconCaches).join([
      innerJoin(
        uguisuNicoliveCommunities,
        uguisuNicoliveCommunityIconCaches.community.equalsExp(uguisuNicoliveCommunities.id),
      ),
    ])
      ..where(uguisuNicoliveCommunities.serviceId.equals('nicolive') & uguisuNicoliveCommunities.communityId.equals(communityId))
  ).getSingleOrNull();

  if (joinedResult == null) {
    mainLogger.info('loadCommunityIconCache: Cache-miss for community_icon/$communityId');
    return null;
  }

  mainLogger.fine('loadCommunityIconCache: Cache-hit for community_icon/$communityId');

  final communityIconCache = joinedResult.readTable(uguisuNicoliveCommunityIconCaches);
  final community = joinedResult.readTable(uguisuNicoliveCommunities);

  final iconFile = File(communityIconCache.path);
  if (! await iconFile.exists()) {
    mainLogger.warning('Unexpected cache-miss for community_icon/$communityId. User icon image file not exists');
    return null;
  }

  final iconBytes = await iconFile.readAsBytes();

  return NiconicoCommunityIconCache(
    communityId: communityId,
    communityIcon: NiconicoCommunityIcon(
      iconUri: Uri.parse(community.iconUrl),
      contentType: communityIconCache.contentType,
      iconBytes: iconBytes,
    ),
    iconUploadedAt: communityIconCache.uploadedAt,
    iconFetchedAt: communityIconCache.fetchedAt,
  );
}

Future<void> saveCommunityIconCache(NiconicoCommunityIconCache communityIcon) async {
  final uguisuNicoliveCommunityIconCaches = uguisuDatabase!.uguisuNicoliveCommunityIconCaches;
  final uguisuNicoliveCommunities = uguisuDatabase!.uguisuNicoliveCommunities;

  final communityId = communityIcon.communityId;
  final contentType = communityIcon.communityIcon.contentType;

  String? iconFileNameSuffix;
  if (contentType == 'image/png') iconFileNameSuffix = '.png';
  if (contentType == 'image/jpeg') iconFileNameSuffix = '.jpg';
  if (contentType == 'image/gif') iconFileNameSuffix = '.gif';
  if (iconFileNameSuffix == null) {
    throw Exception('Unsupported content type: $contentType');
  }

  final appSupportDir = await getApplicationSupportDirectory();
  final iconFile = File(path.join(appSupportDir.path, 'cache/community_icon/$communityId$iconFileNameSuffix'));
  await iconFile.parent.create(recursive: true);
  await iconFile.writeAsBytes(communityIcon.communityIcon.iconBytes, flush: true);

  final community = await (uguisuDatabase!.select(uguisuNicoliveCommunities)..where((tbl) => tbl.communityId.equals(communityId))).getSingleOrNull();
  if (community == null) {
    throw Exception('Community cache not found for community/$communityId');
  }

  final rowId = await uguisuDatabase!.into(uguisuNicoliveCommunityIconCaches).insert(
    UguisuNicoliveCommunityIconCachesCompanion.insert(
      community: community.id,
      contentType: communityIcon.communityIcon.contentType,
      path: iconFile.path,
      uploadedAt: Value(communityIcon.iconUploadedAt),
      fetchedAt: communityIcon.iconFetchedAt,
    ),
    onConflict: DoUpdate.withExcluded(
      (old, excluded) => UguisuNicoliveCommunityIconCachesCompanion.custom(
        contentType: excluded.contentType,
        path: excluded.path,
        uploadedAt: excluded.uploadedAt,
        fetchedAt: excluded.fetchedAt,
      ),
      target: [uguisuNicoliveCommunityIconCaches.community],
    ),
  );

  mainLogger.info('saveCommunityIconCache: Community icon community/$communityId cache saved (rowid=$rowId)');
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
  Future<Uri> getCommunityPageUri(String communityId) async {
    // TODO: use local emulation server if not live.nicovideo.jp
    return Uri.parse('https://com.nicovideo.jp/community/$communityId');
    // if (livePageUrl.startsWith('https://live.nicovideo.jp/watch/')) {
    //   return Uri.parse('https://com.nicovideo.jp/community/$communityId');
    // }
    // return Uri.parse('http://127.0.0.1:10085/community_page/$communityId');
  }

  await simpleClient!.initialize(
    loginCookie: loginCookie,
    getUserPageUri: getUserPageUri,
    userPageLoadCacheOrNull: (userId) async {
      final userPageCache = await (
        uguisuDatabase!.select(uguisuDatabase!.uguisuNicoliveUsers)
          ..where((tbl) => tbl.serviceId.equals('nicolive') & tbl.userId.equals(userId))
      ).getSingleOrNull();

      if (userPageCache == null) {
        mainLogger.info('userPageLoadCacheOrNull: Cache-miss for user/$userId');
        return null;
      }

      return NiconicoUserPageCache(
        userId: userId,
        userPage: NiconicoUserPage(
          id: userId,
          nickname: userPageCache.nickname,
          iconUrl: userPageCache.iconUrl,
        ),
        pageFetchedAt: userPageCache.fetchedAt,
      );
    },
    userPageSaveCache: (userPage) async {
      final userId = userPage.userId;
      final uguisuNicoliveUsers = uguisuDatabase!.uguisuNicoliveUsers;

      await uguisuDatabase!.into(uguisuNicoliveUsers).insert(
        UguisuNicoliveUsersCompanion.insert(
          serviceId: 'nicolive',
          userId: userId,
          nickname: userPage.userPage.nickname,
          iconUrl: userPage.userPage.iconUrl,
          fetchedAt: userPage.pageFetchedAt,
        ),
        onConflict: DoUpdate.withExcluded(
          (old, excluded) => UguisuNicoliveUsersCompanion.custom(
            nickname: excluded.nickname,
            iconUrl: excluded.iconUrl,
            fetchedAt: excluded.fetchedAt,
          ),
          target: [uguisuNicoliveUsers.serviceId, uguisuNicoliveUsers.userId],
        ),
      );
    },
    userIconLoadCacheOrNull: loadUserIconCache,
    userIconSaveCache: saveUserIconCache,
    getCommunityPageUri: getCommunityPageUri,
    communityPageLoadCacheOrNull: (communityId) async {
      final communityPageCache = await (
        uguisuDatabase!.select(uguisuDatabase!.uguisuNicoliveCommunities)
          ..where((tbl) => tbl.serviceId.equals('nicolive') & tbl.communityId.equals(communityId))
      ).getSingleOrNull();

      if (communityPageCache == null) {
        mainLogger.info('communityPageLoadCacheOrNull: Cache-miss for community/$communityId');
        return null;
      }

      return NiconicoCommunityPageCache(
        communityId: communityId,
        communityPage: NiconicoCommunityPage(
          id: communityId,
          name: communityPageCache.name,
          iconUrl: communityPageCache.iconUrl,
        ),
        pageFetchedAt: communityPageCache.fetchedAt,
      );
    },
    communityPageSaveCache: (communityPage) async {
      final uguisuNicoliveCommunities = uguisuDatabase!.uguisuNicoliveCommunities;
      final communityId = communityPage.communityId;

      await uguisuDatabase!.into(uguisuNicoliveCommunities).insert(
        UguisuNicoliveCommunitiesCompanion.insert(
          serviceId: 'nicolive',
          communityId: communityId,
          name: communityPage.communityPage.name,
          iconUrl: communityPage.communityPage.iconUrl,
          fetchedAt: communityPage.pageFetchedAt,
        ),
        onConflict: DoUpdate.withExcluded(
          (old, excluded) => UguisuNicoliveCommunitiesCompanion.custom(
            name: excluded.name,
            iconUrl: excluded.iconUrl,
            fetchedAt: excluded.fetchedAt,
          ),
          target: [uguisuNicoliveCommunities.serviceId, uguisuNicoliveCommunities.communityId],
        ),
      );
    },
    communityIconLoadCacheOrNull: loadCommunityIconCache,
    communityIconSaveCache: saveCommunityIconCache,
  );
}

// Live Page
Future<NiconicoLivePage?> loadLivePage({
  required String programId,
}) async {
  final uguisuNicolivePrograms = uguisuDatabase!.uguisuNicolivePrograms;
  final uguisuNicoliveUsers = uguisuDatabase!.uguisuNicoliveUsers;
  final uguisuNicoliveCommunities = uguisuDatabase!.uguisuNicoliveCommunities;

  final joinedResult = await (
    uguisuDatabase!.select(uguisuNicolivePrograms).join([
      innerJoin(
        uguisuNicoliveUsers,
        uguisuNicolivePrograms.community.equalsExp(uguisuNicoliveCommunities.id),
      ),
      innerJoin(
        uguisuNicoliveCommunities,
        uguisuNicolivePrograms.user.equalsExp(uguisuNicoliveUsers.id),
      ),
    ])
      ..where(uguisuNicolivePrograms.serviceId.equals('nicolive') & uguisuNicolivePrograms.programId.equals(programId))
  ).getSingleOrNull();

  if (joinedResult == null) {
    mainLogger.info('loadLivePage: Cache-miss for program/$programId');
    return null;
  }

  final livePageCache = joinedResult.readTable(uguisuNicolivePrograms);
  final supplierUser = joinedResult.readTable(uguisuNicoliveUsers);
  final supplierCommunity = joinedResult.readTable(uguisuNicoliveCommunities);

  return NiconicoLivePage(
    webSocketUrl: livePageCache.webSocketUrl,
    program: NiconicoLivePageProgram(
      title: livePageCache.title,
      nicoliveProgramId: programId,
      providerType: livePageCache.providerType,
      visualProviderType: livePageCache.visualProviderType,
      supplier: NiconicoLivePageProgramSupplier(
        name: supplierUser.nickname,
        programProviderId: supplierUser.userId.toString(),
      ),
      beginTime: (livePageCache.beginTime.millisecondsSinceEpoch / 1000).floor(), // in seconds
      endTime: (livePageCache.endTime.millisecondsSinceEpoch / 1000).floor(), // in seconds
    ),
    socialGroup: NiconicoLivePageSocialGroup(
      id: supplierCommunity.communityId,
      name: supplierCommunity.name,
      iconUrl: supplierCommunity.iconUrl,
    ),
    pageFetchedAt: livePageCache.fetchedAt,
  );
}

Future<void> saveLivePage({
  required NiconicoLivePage livePage,
}) async {
  final uguisuNicolivePrograms = uguisuDatabase!.uguisuNicolivePrograms;

  final userId = int.parse(livePage.program.supplier.programProviderId);
  final userPageUri = await simpleClient!.getUserPageUri!.call(userId);

  await simpleClient!.userPageCacheClient!.loadOrFetchUserPage(userId: userId, userPageUri: userPageUri);

  final userPageCache =  await (uguisuDatabase!.select(uguisuDatabase!.uguisuNicoliveUsers)
    ..where((tbl) => tbl.serviceId.equals('nicolive') & tbl.userId.equals(userId))
  ).getSingle();

  final communityId = livePage.socialGroup.id;
  final communityPageUri = await simpleClient!.getCommunityPageUri!.call(communityId);

  await simpleClient!.communityPageCacheClient!.loadOrFetchCommunityPage(communityId: communityId, communityPageUri: communityPageUri);

  final communityPageCache =  await (uguisuDatabase!.select(uguisuDatabase!.uguisuNicoliveCommunities)
    ..where((tbl) => tbl.serviceId.equals('nicolive') & tbl.communityId.equals(communityId))
  ).getSingle();

  await uguisuDatabase!.into(uguisuNicolivePrograms).insert(
    UguisuNicoliveProgramsCompanion.insert(
      serviceId: 'nicolive',
      programId: livePage.program.nicoliveProgramId,
      title: livePage.program.title,
      providerType: livePage.program.providerType,
      visualProviderType: livePage.program.visualProviderType,
      beginTime: DateTime.fromMillisecondsSinceEpoch(livePage.program.beginTime * 1000, isUtc: true),
      endTime: DateTime.fromMillisecondsSinceEpoch(livePage.program.endTime * 1000, isUtc: true),
      user: userPageCache.id,
      community: communityPageCache.id,
      webSocketUrl: livePage.webSocketUrl,
      fetchedAt: livePage.pageFetchedAt,
    ),
    onConflict: DoUpdate.withExcluded(
      (old, excluded) => UguisuNicoliveProgramsCompanion.custom(
        title: excluded.title,
        providerType: excluded.providerType,
        visualProviderType: excluded.visualProviderType,
        beginTime: excluded.beginTime,
        endTime: excluded.endTime,
        user: excluded.user,
        community: excluded.community,
        webSocketUrl: excluded.webSocketUrl,
        fetchedAt: excluded.fetchedAt,
      ),
      target: [uguisuNicolivePrograms.serviceId, uguisuNicolivePrograms.programId],
    ),
  );
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

class SimpleNiconicoCommunityIconImageBytesResolver with NiconicoCommunityIconImageBytesResolver {
  @override
  Future<Uint8List>? resolveCommunityIconImageBytes({required String communityId}) async {
    final communityPageCache = await simpleClient!.communityPageCacheClient!.loadOrFetchCommunityPage(communityId: communityId, communityPageUri: Uri.parse('https://com.nicovideo.jp/community/$communityId'));
    final communityIconCache = await simpleClient!.communityIconCacheClient!.loadOrFetchIcon(communityId: communityId, iconUri: Uri.parse(communityPageCache.communityPage.iconUrl));

    return communityIconCache.communityIcon.iconBytes;
  }
}

class SimpleNiconicoLocalCachedCommunityIconImageFileResolver with NiconicoLocalCachedCommunityIconImageFileResolver {
  @override
  Future<File?> resolveLocalCachedCommunityIconImageFile({required String communityId}) async {
    final iconPath = await getCommunityIconPath(communityId);
    return iconPath != null ? File(iconPath) : null;
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
  NiconicoCommunityIconCache? livePageSupplierCommunityIconCache;
  ScheduleMessage? scheduleMessage;
  StatisticsMessage? statisticsMessage;
  List<BaseChatMessage> chatMessages = [];

  bool fetchAllRunning = false;

  final liveIdOrUrlTextController = TextEditingController(text: '');
  final chatMessageListScrollController = ScrollController();

  final chatMessageAddPool = Pool(1);
  final chatMessageLazyResolverPool = Pool(1);

  Logger? logger;

  @override
  void initState() {
    super.initState();

    final logger = Logger('main');
    this.logger = logger;
  }

  Future<List<BaseChatMessage>> resolveAllLazyChatMessages(List<BaseChatMessage> chatMessages, bool disconnect) async {
    final localResolverPool = Pool(5);
    final nextChatMessages = [...chatMessages];

    for (var i=0; i<nextChatMessages.length; i+=1) {
      final chatMessageIndex = i;
      // logger?.fine('resolveLazyChatMessages: schedule resolving comment no. ${nextChatMessages[chatMessageIndex].chatMessage.no} (${chatMessageIndex+1}/${nextChatMessages.length})');

      localResolverPool.withResource(() async {
        var cm = nextChatMessages[chatMessageIndex];
        // logger?.fine('resolveLazyChatMessages: resolving comment no. ${cm.chatMessage.no}');

        if (cm is LazyNormalChatMessage) {
          logger?.fine('resolveLazyChatMessages: no. ${cm.chatMessage.no} is LazyNormalChatMessage');
          cm = await cm.resolve();
        }

        if (cm is DisconnectChatMessage) {
          logger?.fine('resolveLazyChatMessages: no. ${cm.chatMessage.no} is DisconnectChatMessage');
          if (disconnect) {
            logger?.info('Close websocket connection due to the disconnect chat message (No. ${cm.chatMessage.no})');
            simpleClient?.disconnect();
          } else {
            logger?.fine('resolveLazyChatMessages: Disconnect message no. ${cm.chatMessage.no} is ignored');
          }
        }

        // logger?.fine('resolveLazyChatMessages: resolved no. ${cm.chatMessage.no}');
        nextChatMessages[chatMessageIndex] = cm;
      });
    }

    logger?.fine('resolveLazyChatMessages: wait until resolver poll consuming done');
    await localResolverPool.close();
    logger?.fine('resolveLazyChatMessages: resolver poll consuming done');

    return nextChatMessages;
  }

  Future<void> addAllChatMessagesIfNotExists({
    required Iterable<BaseChatMessage> chatMessages,
  }) async {
    final nextChatMessages = [...this.chatMessages];

    for (final chatMessage in chatMessages) {
      final found = this.chatMessages.any((other) =>
        chatMessage.chatMessage.thread == other.chatMessage.thread && 
        chatMessage.chatMessage.no == other.chatMessage.no
      );
      if (found) continue;

      nextChatMessages.add(chatMessage);
    }

    // ListViewの個数が変わる前にatBottomを検査
    final isScrollEnd = chatMessageListScrollController.hasClients && chatMessageListScrollController.position.atEdge && chatMessageListScrollController.position.pixels != 0;

    setState(() {
      nextChatMessages.sort((a, b) => a.chatMessage.no.compareTo(b.chatMessage.no));

      this.chatMessages = nextChatMessages;
    });

    // ListViewの個数が変わってから末尾までスクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isScrollEnd) {
        chatMessageListScrollController.jumpTo(chatMessageListScrollController.position.maxScrollExtent);
      }
    });

    await Future(() async {
      await chatMessageLazyResolverPool.withResource(() async {
        mainLogger.info('chatMessageLazyResolverPool: Start resolving lazy messages');
        final nextChatMessages = await resolveAllLazyChatMessages(this.chatMessages, true);
        mainLogger.info('chatMessageLazyResolverPool: Update resolved messages');
        setState(() {
          this.chatMessages = nextChatMessages;
        });
      });
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

        await simpleClient!.fetchLivePage(
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
            logger?.fine('onChatMessage: no. ${chatMessage.chatMessage.no}');

            chatMessageAddPool.withResource(() async {
              addChatMessageIfNotExists(chatMessage: chatMessage);
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
        final livePage = simpleClient!.livePage!;
        final livePageSupplierCommunityPageCache = await simpleClient!.communityPageCacheClient!.loadOrFetchCommunityPage(communityId: livePage.socialGroup.id, communityPageUri: await simpleClient!.getCommunityPageUri!.call(livePage.socialGroup.id));
        final livePageSupplierCommunityIconCache = await simpleClient!.communityIconCacheClient!.loadOrFetchIcon(communityId: livePage.socialGroup.id, iconUri: Uri.parse(livePageSupplierCommunityPageCache.communityPage.iconUrl));

        final liveUserId = int.parse(livePage.program.supplier.programProviderId);
        final livePageSupplierUserPageCache = await simpleClient!.userPageCacheClient!.loadOrFetchUserPage(userId: liveUserId, userPageUri: await simpleClient!.getUserPageUri!.call(liveUserId));
        final livePageSupplierUserIconCache = await simpleClient!.userIconCacheClient!.loadOrFetchIcon(userId: liveUserId, iconUri: Uri.parse(livePageSupplierUserPageCache.userPage.iconUrl));

        await saveLivePage(
          livePage: livePage,
        );

        setState(() {
          this.livePage = livePage;
          this.livePageSupplierUserPageCache = livePageSupplierUserPageCache;
          this.livePageSupplierUserIconCache = livePageSupplierUserIconCache;
          this.livePageSupplierCommunityIconCache = livePageSupplierCommunityIconCache;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future(() async {
            await simpleClient!.connect();
          });
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
            communityIconImageBytesResolver: SimpleNiconicoCommunityIconImageBytesResolver(),
            communityLocalCachedIconImageFileResolver: SimpleNiconicoLocalCachedCommunityIconImageFileResolver(),
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

                        // FIXME: simpleClient can be disconnect here when disconnect message received?
                        newChatMessages.addAll(thread.chatMessages.map((chatMessage) => simpleClient!.parseChatMessage(chatMessage)).toList());

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
