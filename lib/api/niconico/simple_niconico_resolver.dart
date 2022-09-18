import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:uguisu/main.dart';
import 'niconico_resolver.dart';

class SimpleNiconicoResolver
  with
    NiconicoUserPageUriResolver,
    NiconicoLocalCachedUserIconImageFileResolver,
    NiconicoUserIconImageBytesResolver,
    NiconicoCommunityPageUriResolver
{
  final Logger logger = Logger('com.aoirint.uguisu.common.niconico.niconico_resolver.SimpleNiconicoResolver');

  final NiconicoLoginCookie? loginCookie;

  final userId2imageBytes = <int, Uint8List>{};

  SimpleNiconicoResolver({
    this.loginCookie,
  });

  @override
  Future<Uri?> resolveUserPageUri({required int userId}) async {
    return Uri.parse('https://www.nicovideo.jp/user/$userId');
  }

  @override
  Future<Uri?> resolveCommunityPageUri({required String communityId}) async {
    return Uri.parse('https://com.nicovideo.jp/community/$communityId');
  }

  @override
  Future<File?> resolveLocalCachedUserIconImageFile({required int userId}) async {
    final userIconJsonFile = File(await getUserIconJsonLocalCachePath(userId: userId));
    if (! await userIconJsonFile.exists()) {
      logger.warning('User icon path cache-miss for user/$userId. User icon json not found');
      return null;
    }

    final userIconRawJson = await userIconJsonFile.readAsString(encoding: utf8);
    final userIconJson = jsonDecode(userIconRawJson);

    if (userIconJson['version'] != '1') {
      logger.warning('User icon path cache-miss for user/$userId. Unsupported user icon json version. Ignore this: ${userIconJsonFile.path}');
      return null;
    }

    final userIdInJson = userIconJson['userId'];
    if (userIdInJson != userId) {
      throw Exception('Invalid user icon json. userId does not match. given: $userId, json: $userIdInJson');
    }

    final String iconPath = userIconJson['iconPath'];
    return File(iconPath);
  }

  Future<String> getUserIconJsonLocalCachePath({required int userId}) async {
    final appSupportDir = await getApplicationSupportDirectory();
    return path.join(appSupportDir.path, 'cache/user_icon/$userId.json');
  }

  Future<String> createNewUserIconImageLocalCachePath({required int userId, required String contentType}) async {
    final appSupportDir = await getApplicationSupportDirectory();

    String? iconFileNameSuffix;
    if (contentType == 'image/png') iconFileNameSuffix = '.png';
    if (contentType == 'image/jpeg') iconFileNameSuffix = '.jpg';
    if (contentType == 'image/gif') iconFileNameSuffix = '.gif';
    if (iconFileNameSuffix == null) {
      throw Exception('Unsupported content type: $contentType');
    }

    return path.join(appSupportDir.path, 'cache/user_icon/$userId$iconFileNameSuffix');
  }

  @override
  Future<Uint8List>? resolveUserIconImageBytes({required int userId}) async {
    // On-memory cache
    final onMemoryCachedUserIconImageBytes =  userId2imageBytes[userId];
    if (onMemoryCachedUserIconImageBytes != null) {
      logger.fine('User icon image bytes on-memory-cache-hit for user/$userId');
      return onMemoryCachedUserIconImageBytes;
    }

    // Local cache
    final localCachedUserIconFile = await resolveLocalCachedUserIconImageFile(userId: userId);
    if (localCachedUserIconFile != null) {
      return await localCachedUserIconFile.readAsBytes();
    }

    // TODO: Network request
    // final newLocalCachePath = createNewUserIconImageLocalCachePath(userId: userId, contentType: contentType);

    throw UnimplementedError();
  }
}
