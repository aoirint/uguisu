import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';

class NiconicoLivePage {
  String webSocketUrl;

  NiconicoLivePage({required this.webSocketUrl});
}

class NiconicoLivePageClient {
  late Logger logger;

  NiconicoLivePageClient() {
    logger = Logger('NiconicoLivePageClient');
  }

  Future<NiconicoLivePage> get({
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
    final embeddedDataElement = document.querySelector('#embedded-data');
    if (embeddedDataElement == null) {
      throw Exception('Element #embedded-data not found');
    }

    final rawDataProps = embeddedDataElement.attributes['data-props'];
    if (rawDataProps == null) {
      throw Exception('Element #embedded-data attribute data-props not found');
    }

    final props = jsonDecode(rawDataProps);
    final site = props['site'];
    final relive = site['relive'];
    final webSocketUrl = relive['webSocketUrl'];

    return NiconicoLivePage(
      webSocketUrl: webSocketUrl,
    );
  }
}
