import 'package:drift/drift.dart' hide Column;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uguisu/database/uguisu_database.dart';
import 'package:uguisu/niconico_live/community_icon_client.dart';
import 'package:uguisu/niconico_live/community_icon_cache_client.dart';
import 'package:uguisu/main.dart';

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
