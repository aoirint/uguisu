import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';

class NiconicoUserPage {
  int id;
  String nickname;
  String iconUrl;

  NiconicoUserPage({
    required this.id,
    required this.nickname,
    required this.iconUrl,
  });
}

class NiconicoUserPageClient {
  late Logger logger;

  NiconicoUserPageClient() {
    logger = Logger('NiconicoUserPageClient');
  }

  Future<NiconicoUserPage> get({
    required Uri uri,
    required String userAgent,
  }) async {
    final response = await http.get(uri, headers: {
      'User-Agent': userAgent,
    });
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
    final initConfig = initialData['initConfig'];
    final userDetails1 = initConfig['userDetails'];
    final userDetails2 = userDetails1['userDetails'];
    final user = userDetails2['user'];
    final id = user['id'];
    final nickname = user['nickname'];
    final icons = user['icons'];
    final iconUrl = icons['large'];

    return NiconicoUserPage(
      id: id,
      nickname: nickname,
      iconUrl: iconUrl,
    );
  }
}
