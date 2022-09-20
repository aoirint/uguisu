import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:uguisu/niconico_live/cookie_util.dart';

class NiconicoUserPage {
  int id;
  bool anonymity;
  String? nickname;
  String? iconUrl;

  NiconicoUserPage({
    required this.id,
    required this.anonymity,
    this.nickname,
    this.iconUrl,
  });
}

class NiconicoUserPageClient {
  late Logger logger;

  NiconicoUserPageClient() {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoUserPageClient#$hashCode');
  }

  Future<NiconicoUserPage> get({
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
    final jsInitialUserPageDataElement = document.querySelector('#js-initial-userpage-data');
    if (jsInitialUserPageDataElement == null) {
      throw Exception('Element #js-initial-userpage-data not found');
    }

    final rawDataInitialData = jsInitialUserPageDataElement.attributes['data-initial-data'];
    if (rawDataInitialData == null) {
      throw Exception('Element #js-initial-userpage-data attribute data-initial-data not found');
    }

    final initialData = jsonDecode(rawDataInitialData);
    final userDetails1 = initialData['userDetails'];
    final userDetails2 = userDetails1['userDetails'];
    final user = userDetails2['user'];
    final id = user['id'];
    final nickname = user['nickname'];
    final icons = user['icons'];
    final iconUrl = icons['large'];

    return NiconicoUserPage(
      id: id,
      anonymity: false,
      nickname: nickname,
      iconUrl: iconUrl,
    );
  }
}
