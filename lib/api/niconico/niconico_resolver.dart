import 'dart:io';
import 'dart:typed_data';

import 'package:uguisu/niconico_live/login_client.dart';

abstract class NiconicoUserPageUriResolver {
  Future<Uri?> resolveUserPageUri({required int userId});
}

abstract class NiconicoLocalCachedUserIconImageFileResolver {
  Future<File?> resolveLocalCachedUserIconImageFile({required int userId});
}

abstract class NiconicoUserIconImageBytesResolver {
  Future<Uint8List>? resolveUserIconImageBytes({required int userId});
}

abstract class NiconicoCommunityPageUriResolver {
  Future<Uri?> resolveCommunityPageUri({required String communityId});
}

abstract class NiconicoLocalCachedCommunityIconImageFileResolver {
  Future<File?> resolveLocalCachedCommunityIconImageFile({required String communityId});
}

abstract class NiconicoCommunityIconImageBytesResolver {
  Future<Uint8List>? resolveCommunityIconImageBytes({required String communityId});
}

abstract class NiconicoLivePageUriResolver {
  Future<Uri?> resolveLivePageUri({required String liveIdOrUrl});
}

abstract class NiconicoLoginResolver {
  Future<NiconicoLoginResult?> resolveLogin({required String mailTel, required String password});
}

abstract class NiconicoMfaLoginResolver {
  Future<NiconicoMfaLoginResult?> resolveMfaLogin({required String otp, required String deviceName});
}
