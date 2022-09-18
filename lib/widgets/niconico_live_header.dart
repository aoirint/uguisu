
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';

import 'package:uguisu/api/niconico/niconico_resolver.dart';

final Logger logger = Logger('com.aoirint.uguisu.lib.widgets.NiconicoLiveHeader');

class NiconicoLiveHeader extends StatefulWidget {
  final String livePageUrl;
  final String liveId;
  final String liveTitle;
  final DateTime liveBeginDateTime;

  final NiconicoUserIconImageBytesResolver userIconImageBytesResolver;
  final NiconicoLocalCachedUserIconImageFileResolver userLocalCachedIconImageFileResolver;
  final NiconicoUserPageUriResolver userPageUriResolver;
  final NiconicoCommunityPageUriResolver communityPageUriResolver;

  final int supplierUserId;
  final String supplierUserName;

  final String supplierCommunityId;
  final String supplierCommunityName;

  const NiconicoLiveHeader({
    super.key,
    required this.livePageUrl,
    required this.liveId,
    required this.liveTitle,
    required this.liveBeginDateTime,
    required this.userIconImageBytesResolver,
    required this.userLocalCachedIconImageFileResolver,
    required this.userPageUriResolver,
    required this.communityPageUriResolver,
    required this.supplierUserId,
    required this.supplierUserName,
    required this.supplierCommunityId,
    required this.supplierCommunityName,
  });

  @override
  State<NiconicoLiveHeader> createState() => _NiconicoLiveHeaderState();
}

class _NiconicoLiveHeaderState extends State<NiconicoLiveHeader> {
  Uint8List? supplierUserIconBytes;

  @override
  Widget build(BuildContext context) {
    Future(() async {
      if (supplierUserIconBytes == null) {
        final supplierUserIconBytes = await widget.userIconImageBytesResolver.resolveUserIconImageBytes(userId: widget.supplierUserId);
        if (supplierUserIconBytes == null) {
          logger.warning('User icon bytes is not found for the user ID = ${widget.supplierUserId}');
        }

        setState(() {
          this.supplierUserIconBytes = supplierUserIconBytes;
        });
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final iconPath = await widget.userLocalCachedIconImageFileResolver.resolveLocalCachedUserIconImageFile(userId: widget.supplierUserId);
                if (iconPath == null) {
                  logger.warning('User icon path is not found for the user ID = ${widget.supplierUserId}');
                  return;
                }

                await OpenFilex.open(iconPath.path);
              },
              child: Tooltip(
                message: 'アイコンの画像ファイル（キャッシュ）を開く',
                child: Row(
                  children: [
                    SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: FittedBox(child: supplierUserIconBytes != null ? Image.memory(supplierUserIconBytes!) : const Icon(Icons.account_box)),
                      // child: FittedBox(child: Icon(Icons.account_box)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
              child: Tooltip(
                message: '放送ページを開く\nID: ${widget.liveId}',
                child: Text.rich(
                  TextSpan(
                    text: widget.liveTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    mouseCursor: SystemMouseCursors.click,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (!await launchUrlString(widget.livePageUrl)) {
                          throw Exception('Failed to open URL: ${widget.livePageUrl}');
                        }
                      },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                  child: Tooltip(
                    message: '放送者のユーザーページを開く\nID: ${widget.supplierUserId}',
                    child: Text.rich(
                      TextSpan(
                        text: widget.supplierUserName,
                        style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final uri = await widget.userPageUriResolver.resolveUserPageUri(userId: widget.supplierUserId);

                            if (uri == null) {
                              logger.warning('User page uri is not found for the user ID = ${widget.supplierUserId}');
                              return;
                            }

                            if (!await launchUrl(uri)) {
                              throw Exception('Failed to open URL: ${uri.toString()}');
                            }
                          },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                  child: Tooltip(
                    message: '放送中のコミュニティページを開く\nID: ${widget.supplierCommunityId}',
                    child: Text.rich(
                      TextSpan(
                        text: widget.supplierCommunityName,
                        style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final uri = await widget.communityPageUriResolver.resolveCommunityPageUri(communityId: widget.supplierCommunityId);

                            if (uri == null) {
                              logger.warning('Community page uri is not found for the community ID = ${widget.supplierCommunityId}');
                              return;
                            }

                            if (!await launchUrl(uri)) {
                              throw Exception('Failed to open URL: ${uri.toString()}');
                            }
                          },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                  child: Text('開始 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.liveBeginDateTime.toLocal())}')
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 8.0),
                //   child: Text('終了 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(livePage!.program.endTime * 1000, isUtc: true).toLocal())}')
                // ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
}