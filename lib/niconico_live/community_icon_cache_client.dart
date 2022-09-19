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

  NiconicoCommunityIconCacheClient({
    this.cookieJar,
    required this.userAgent,
    required this.loadCacheOrNull,
    required this.saveCache,
  });

  Future<NiconicoCommunityIconCache> loadOrFetchIcon({
    required String communityId,
    required Uri iconUri,
  }) async {
    final cache = await loadCacheOrNull(communityId);
    if (cache != null) {
      return cache;
    }

    final now = DateTime.now();
    final communityIcon = await NiconicoCommunityIconClient().get(uri: iconUri, cookieJar: cookieJar, userAgent: userAgent);

    final uriQuery = iconUri.query; // '?' excluded
    final iconUploadedAt = uriQuery != '' ? DateTime.fromMillisecondsSinceEpoch(int.parse(uriQuery) * 1000, isUtc: true) : null;

    final fetchedCache = NiconicoCommunityIconCache(communityId: communityId, communityIcon: communityIcon, iconUploadedAt: iconUploadedAt, iconFetchedAt: now);
    await saveCache(fetchedCache);

    return fetchedCache;
  }
}
