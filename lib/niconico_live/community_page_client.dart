import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:uguisu/niconico_live/cookie_util.dart';

class NiconicoCommunityPage {
  String id;
  String name;
  String iconUrl;

  NiconicoCommunityPage({
    required this.id,
    required this.name,
    required this.iconUrl,
  });
}

class NiconicoCommunityPageClient {
  late final Logger logger;

  NiconicoCommunityPageClient() {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoCommunityPageClient#$hashCode');
  }

  Future<NiconicoCommunityPage> get({
    required Uri uri,
    SweetCookieJar? cookieJar,
    required String userAgent,
  }) async {
    final headers = {'User-Agent': userAgent};
    if (cookieJar != null) {headers['Cookie'] = formatCookieJarForRequestHeader(cookieJar);}

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Request failed. Status ${response.statusCode}');
    }

    final responseBody = response.body;
    final document = parse(responseBody);
    final areaCommunityHeader = document.querySelector('.area-communityHeader');
    if (areaCommunityHeader == null) {
      throw Exception('Element .area-communityHeader not found');
    }

    final communityThumbnailAnchor = areaCommunityHeader.querySelector('.communityThumbnail > a');
    if (communityThumbnailAnchor == null) {
      throw Exception('Element .communityThumbnail > a not found');
    }

    final communityThumbnailAnchorUrl = communityThumbnailAnchor.attributes['href'];
    if (communityThumbnailAnchorUrl == null) {
      throw Exception('Attribute href of Element .communityThumbnail > a must be defined');
    }

    final communityId = path.basename(communityThumbnailAnchorUrl); // href: /community/co0000000

    final communityThumbnailAnchorImage = communityThumbnailAnchor.querySelector('img');
    if (communityThumbnailAnchorImage == null) {
      throw Exception('Element img not found');
    }
    final iconUrl = communityThumbnailAnchorImage.attributes['src'];
    if (iconUrl == null) {
      throw Exception('Attribute src must be defined');
    }

    final communityData = areaCommunityHeader.querySelector('.communityData');
    if (communityData == null) {
      throw Exception('Element .communityData not found');
    }

    final titleElement = communityData.querySelector('.title');
    if (titleElement == null) {
      throw Exception('Element .title not found');
    }

    final communityName = titleElement.text.trim();

    return NiconicoCommunityPage(
      id: communityId,
      name: communityName,
      iconUrl: iconUrl,
    );
  }
}
