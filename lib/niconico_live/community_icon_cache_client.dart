import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

import 'community_icon_client.dart';

class NiconicoCommunityIconCache {
  String communityId;
  NiconicoCommunityIcon communityIcon;
  DateTime? iconUploadedAt;
  DateTime iconFetchedAt;

  NiconicoCommunityIconCache({
    required this.communityId,
    required this.communityIcon,
    this.iconUploadedAt,
    required this.iconFetchedAt,
  });
}

class NiconicoCommunityIconCacheClient {
  SweetCookieJar? cookieJar;
  String userAgent;
  Future<NiconicoCommunityIconCache?> Function(String communityId) loadCacheOrNull;
  Future<void> Function(NiconicoCommunityIconCache communityIcon) saveCache;

  late final Logger logger;

  NiconicoCommunityIconCacheClient({
    this.cookieJar,
    required this.userAgent,
    required this.loadCacheOrNull,
    required this.saveCache,
  }) {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoCommunityIconCacheClient#$hashCode');
  }

  Future<NiconicoCommunityIconCache> loadOrFetchIcon({
    required String communityId,
    required Uri iconUri,
  }) async {
    final cache = await loadCacheOrNull(communityId);
    if (cache != null) {
      return cache;
    }
    logger.fine('CommunityIcon Cache-miss for community/$communityId');

    final now = DateTime.now();
    final communityIcon = await NiconicoCommunityIconClient().get(uri: iconUri, cookieJar: cookieJar, userAgent: userAgent);

    final fetchedCache = NiconicoCommunityIconCache(communityId: communityId, communityIcon: communityIcon, iconFetchedAt: now);
    await saveCache(fetchedCache);

    return fetchedCache;
  }
}
