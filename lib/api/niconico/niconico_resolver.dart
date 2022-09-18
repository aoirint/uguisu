import 'dart:io';
import 'dart:typed_data';

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

abstract class NiconicoLivePageUriResolver {
  Future<Uri?> resolveLivePageUri({required String liveIdOrUrl});
}
