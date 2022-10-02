import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

import 'community_page_client.dart';

class NiconicoCommunityPageCache {
  String communityId;
  NiconicoCommunityPage communityPage;
  DateTime pageFetchedAt;

  NiconicoCommunityPageCache({
    required this.communityId,
    required this.communityPage,
    required this.pageFetchedAt,
  });
}

class NiconicoCommunityPageCacheClient {
  SweetCookieJar? cookieJar;
  String userAgent;
  Future<NiconicoCommunityPageCache?> Function(String communityId) loadCacheOrNull;
  Future<void> Function(NiconicoCommunityPageCache communityPage) saveCache;

  late final Logger logger;

  NiconicoCommunityPageCacheClient({
    this.cookieJar,
    required this.userAgent,
    required this.loadCacheOrNull,
    required this.saveCache,
  }) {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoCommunityPageCacheClient#$hashCode');
  }

  Future<NiconicoCommunityPageCache> loadOrFetchCommunityPage({
    required String communityId,
    required Uri communityPageUri,
  }) async {
    final cache = await loadCacheOrNull(communityId);
    if (cache != null) {
      return cache;
    }
    logger.fine('CommunityPage Cache-miss for community/$communityId');

    final now = DateTime.now();
    final communityPage = await NiconicoCommunityPageClient().get(uri: communityPageUri, cookieJar: cookieJar, userAgent: userAgent);

    final fetchedCache = NiconicoCommunityPageCache(communityId: communityId, communityPage: communityPage, pageFetchedAt: now);
    await saveCache(fetchedCache);

    return fetchedCache;
  }
}
