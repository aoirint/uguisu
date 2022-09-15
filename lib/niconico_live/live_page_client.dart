import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:uguisu/niconico_live/cookie_util.dart';

class NiconicoLivePageSocialGroup {
  String id; // community ID, co0000000
  String name;

  NiconicoLivePageSocialGroup({
    required this.id,
    required this.name,
  });
}

class NiconicoLivePageProgramSupplier {
  String name;
  String programProviderId; // userId

  NiconicoLivePageProgramSupplier({
    required this.name,
    required this.programProviderId,
  });
}

class NiconicoLivePageProgram {
  String title;
  NiconicoLivePageProgramSupplier supplier;
  int beginTime; // unix epoch (UTC, seconds)
  int endTime; // unix epoch (UTC, seconds)

  NiconicoLivePageProgram({
    required this.title,
    required this.supplier,
    required this.beginTime,
    required this.endTime,
  });
}

class NiconicoLivePage {
  String webSocketUrl;
  NiconicoLivePageProgram program;
  NiconicoLivePageSocialGroup socialGroup;

  NiconicoLivePage({
    required this.webSocketUrl,
    required this.program,
    required this.socialGroup,
  });
}

class NiconicoLivePageClient {
  late Logger logger;

  NiconicoLivePageClient() {
    logger = Logger('NiconicoLivePageClient');
  }

  Future<NiconicoLivePage> get({
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

    final program = props['program'];
    final programTitle = program['title'];
    final programBeginTime = program['beginTime'];
    final programEndTime = program['endTime'];

    final programSupplier = program['supplier'];
    final programSupplierName = programSupplier['name'];
    final programSupplierProgramProviderId = programSupplier['programProviderId'];

    final socialGroup = props['socialGroup'];
    final socialGroupId = socialGroup['id'];
    final socialGroupName = socialGroup['name'];

    return NiconicoLivePage(
      webSocketUrl: webSocketUrl,
      program: NiconicoLivePageProgram(
        title: programTitle,
        supplier: NiconicoLivePageProgramSupplier(
          name: programSupplierName,
          programProviderId: programSupplierProgramProviderId,
        ),
        beginTime: programBeginTime,
        endTime: programEndTime,
      ),
      socialGroup: NiconicoLivePageSocialGroup(
        id: socialGroupId,
        name: socialGroupName,
      ),
    );
  }
}
