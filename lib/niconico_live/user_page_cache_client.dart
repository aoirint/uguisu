import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

import 'user_page_client.dart';

class NiconicoUserPageCache {
  int userId;
  NiconicoUserPage userPage;
  DateTime pageFetchedAt;

  NiconicoUserPageCache({
    required this.userId,
    required this.userPage,
    required this.pageFetchedAt,
  });
}

class NiconicoUserPageCacheClient {
  SweetCookieJar? cookieJar;
  String userAgent;
  Future<NiconicoUserPageCache?> Function(int userId) loadCacheOrNull;
  Future<void> Function(NiconicoUserPageCache userPage) saveCache;

  NiconicoUserPageCacheClient({
    this.cookieJar,
    required this.userAgent,
    required this.loadCacheOrNull,
    required this.saveCache,
  });

  Future<NiconicoUserPageCache> loadOrFetchUserPage({
    required int userId,
    required Uri userPageUri,
  }) async {
    final cache = await loadCacheOrNull(userId);
    if (cache != null) {
      return cache;
    }

    final now = DateTime.now();
    final userPage = await NiconicoUserPageClient().get(uri: userPageUri, cookieJar: cookieJar, userAgent: userAgent);

    final fetchedCache = NiconicoUserPageCache(userId: userId, userPage: userPage, pageFetchedAt: now);
    await saveCache(fetchedCache);

    return fetchedCache;
  }
}
