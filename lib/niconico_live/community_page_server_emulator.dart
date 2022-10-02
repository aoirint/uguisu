import 'dart:io';
import 'package:logging/logging.dart';

class NiconicoCommunityPageServerEmulator {
  HttpServer? server;
  late Logger logger;

  NiconicoCommunityPageServerEmulator() {
    logger = Logger('NiconicoCommunityPageServerEmulator');
  }

  Future<void> start(String host, int port) async {
    final server = await HttpServer.bind(host, port);

    server
      .listen(
        (request) {
          __handle(request);
        },
        onDone: () {
          logger.info('done');
        },
      );

    logger.info('open http server at http://$host:$port/');
    
    this.server = server;
  }

  Future<void> stop() async {
    logger.info('close http server');
    await server?.close(force: true);
  }

  void __handle(HttpRequest request) {
    final match = RegExp(r'^/community_page/(.+)$').firstMatch(request.uri.path);
    if (match == null) {
      throw Exception('Invalid request path: ${request.uri.path}');
    }

    final communityId = match.group(1);
    if (communityId == null) {
      throw Exception('communityId != null');
    }

    const communityName = 'My Community';
    const communityIconUrl = 'http://127.0.0.1:10086/community_icon/co0000000/0000000.jpg?key=q4kvaae9b1tkqq3zb0iia6mfv2w3gr4kce63zr2duotypfdmb0gyqmfrvu18trb5'; // query key: salted sha256?, length 64

    request.response.write('''
<!DOCTYPE html>
<meta charset="utf-8">

<header class="area-communityHeader">
  <div class="cp-communityHeader">
    <div class="communityInfo">
      <div class="communityThumbnail">
        <a href="/community/$communityId">
          <img src="$communityIconUrl" alt="$communityName">
        </a>
      </div>

      <div class="communityData">
        <h2 calss="title">
          <a href="/community/$communityId">
            $communityName
          </a>
        </h2>
      </div>
    </div>
  </div>
</header>
''');
    request.response.close();
  }
}
