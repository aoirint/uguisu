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

class NiconicoLivePageUserProgramWatch {
  List<String> rejectedReasons;

  NiconicoLivePageUserProgramWatch({
    required this.rejectedReasons,
  });
}

class NiconicoLivePageProgram {
  String title;
  String nicoliveProgramId;
  String providerType;
  String visualProviderType;
  NiconicoLivePageProgramSupplier supplier;
  int beginTime; // unix epoch (UTC, seconds)
  int endTime; // unix epoch (UTC, seconds)

  NiconicoLivePageProgram({
    required this.title,
    required this.nicoliveProgramId,
    required this.providerType,
    required this.visualProviderType,
    required this.supplier,
    required this.beginTime,
    required this.endTime,
  });
}

class NiconicoLivePage {
  String webSocketUrl;
  NiconicoLivePageProgram program;
  NiconicoLivePageSocialGroup socialGroup;
  NiconicoLivePageUserProgramWatch userProgramWatch;

  NiconicoLivePage({
    required this.webSocketUrl,
    required this.program,
    required this.socialGroup,
    required this.userProgramWatch,
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
    final programNicoliveProgramId = program['nicoliveProgramId'];
    final programProviderType = program['providerType'];
    final programVisualProviderType = program['visualProviderType'];
    final programBeginTime = program['beginTime'];
    final programEndTime = program['endTime'];

    final programSupplier = program['supplier'];
    final programSupplierName = programSupplier['name'];
    final programSupplierProgramProviderId = programSupplier['programProviderId'];

    final socialGroup = props['socialGroup'];
    final socialGroupId = socialGroup['id'];
    final socialGroupName = socialGroup['name'];

    final userProgramWatch = props['userProgramWatch'];
    final userProgramWatchRejectedReasons = List<dynamic>.of(userProgramWatch['rejectedReasons']).map((e) => e.toString()).toList(); // empty list List<dynamic> to List<String>

    return NiconicoLivePage(
      webSocketUrl: webSocketUrl,
      program: NiconicoLivePageProgram(
        title: programTitle,
        nicoliveProgramId: programNicoliveProgramId,
        providerType: programProviderType,
        visualProviderType: programVisualProviderType,
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
      userProgramWatch: NiconicoLivePageUserProgramWatch(
        rejectedReasons: userProgramWatchRejectedReasons,
      ),
    );
  }
}
