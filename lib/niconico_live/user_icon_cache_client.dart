import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

import 'user_icon_client.dart';

class NiconicoUserIconCache {
  int userId;
  NiconicoUserIcon userIcon;
  DateTime? iconUploadedAt;
  DateTime iconFetchedAt;

  NiconicoUserIconCache({
    required this.userId,
    required this.userIcon,
    this.iconUploadedAt,
    required this.iconFetchedAt,
  });
}

class NiconicoUserIconCacheClient {
  SweetCookieJar? cookieJar;
  String userAgent;
  Future<NiconicoUserIconCache?> Function(int userId) loadCacheOrNull;
  Future<void> Function(NiconicoUserIconCache userIcon) saveCache;

  late final Logger logger;

  NiconicoUserIconCacheClient({
    this.cookieJar,
    required this.userAgent,
    required this.loadCacheOrNull,
    required this.saveCache,
  }) {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoUserIconCacheClient#$hashCode');
  }

  Future<NiconicoUserIconCache> loadOrFetchIcon({
    required int userId,
    required Uri iconUri,
  }) async {
    final cache = await loadCacheOrNull(userId);
    if (cache != null) {
      return cache;
    }
    logger.fine('UserIcon Cache-miss for user/$userId');

    final now = DateTime.now();
    final userIcon = await NiconicoUserIconClient().get(uri: iconUri, cookieJar: cookieJar, userAgent: userAgent);

    final uriQuery = iconUri.query; // '?' excluded
    final iconUploadedAt = uriQuery != '' ? DateTime.fromMillisecondsSinceEpoch(int.parse(uriQuery) * 1000, isUtc: true) : null;

    final fetchedCache = NiconicoUserIconCache(userId: userId, userIcon: userIcon, iconUploadedAt: iconUploadedAt, iconFetchedAt: now);
    await saveCache(fetchedCache);

    return fetchedCache;
  }
}
