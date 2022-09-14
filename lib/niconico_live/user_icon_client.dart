import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class NiconicoUserIcon {
  Uri iconUri;
  String contentType;
  Uint8List iconBytes;

  NiconicoUserIcon({
    required this.iconUri,
    required this.contentType,
    required this.iconBytes,
  });
}

class NiconicoUserIconClient {
  late Logger logger;

  NiconicoUserIconClient() {
    logger = Logger('NiconicoUserIconClient');
  }

  Future<NiconicoUserIcon> get({
    required Uri uri,
    required String userAgent,
  }) async {
    final response = await http.get(uri, headers: {
      'User-Agent': userAgent,
    });
    if (response.statusCode != 200) {
      throw Exception('Request failed. Status ${response.statusCode}');
    }

    final contentType = response.headers['content-type']; // lower case key
    if (contentType == null) {
      throw Exception('Content-Type header not found');
    }

    final bodyBytes = response.bodyBytes;

    return NiconicoUserIcon(
      iconUri: uri,
      contentType: contentType,
      iconBytes: bodyBytes,
    );
  }
}
