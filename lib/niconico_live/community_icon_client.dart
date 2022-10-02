import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:uguisu/niconico_live/cookie_util.dart';

class NiconicoCommunityIcon {
  Uri iconUri;
  String contentType;
  Uint8List iconBytes;

  NiconicoCommunityIcon({
    required this.iconUri,
    required this.contentType,
    required this.iconBytes,
  });
}

class NiconicoCommunityIconClient {
  late final Logger logger;
  
  NiconicoCommunityIconClient() {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoCommunityIconClient#$hashCode');
  }

  Future<NiconicoCommunityIcon> get({
    required Uri uri,
    SweetCookieJar? cookieJar,
    required String userAgent,
  }) async {
    logger.fine('CommunityIcon request: $uri');

    final headers = {'User-Agent': userAgent};
    if (cookieJar != null) {headers['Cookie'] = formatCookieJarForRequestHeader(cookieJar);}

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Request failed. Status ${response.statusCode}');
    }

    final contentType = response.headers['content-type']; // lower case key
    if (contentType == null) {
      throw Exception('Content-Type header not found');
    }

    final bodyBytes = response.bodyBytes;

    return NiconicoCommunityIcon(
      iconUri: uri,
      contentType: contentType,
      iconBytes: bodyBytes,
    );
  }
}
