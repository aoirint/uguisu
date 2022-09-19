import 'dart:io';
import 'dart:typed_data';
import 'package:logging/logging.dart';

class CommunityIconData {
  String contentType;
  Uint8List bytes;

  CommunityIconData({
    required this.contentType,
    required this.bytes,
  });
}

class NiconicoCommunityIconServerEmulator {
  HttpServer? server;
  late final Logger logger;
  CommunityIconData? Function(String path)? loadIconFromPath;

  NiconicoCommunityIconServerEmulator() {
    logger = Logger('com.aoirint.uguisu.niconico_live.NiconicoCommunityIconServerEmulator#$hashCode');
  }

  Future<void> start({
    required String host,
    required int port,
    required CommunityIconData? Function(String path) loadIconFromPath,
  }) async {
    this.loadIconFromPath = loadIconFromPath;

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
    final iconData = loadIconFromPath?.call(request.uri.path);
    if (iconData == null) {
      throw Exception('No data for path ${request.uri.path}');
    }

    request.response.headers.add('content-type', iconData.contentType); // lower case key
    request.response.add(iconData.bytes);
    request.response.close();
  }
}
