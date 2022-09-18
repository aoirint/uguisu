
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uguisu/niconico_live/niconico_live.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:uguisu/api/niconico/niconico_resolver.dart';

final Logger _logger = Logger('com.aoirint.uguisu.lib.widgets.NiconicoLiveCommentList');

class NiconicoLiveCommentList extends StatefulWidget {
  final ScrollController chatMessageListScrollController;

  final DateTime liveBeginDateTime;

  final List<BaseChatMessage> chatMessages;
  final NiconicoLocalCachedUserIconImageFileResolver userLocalCachedIconImageFileResolver;
  final NiconicoUserPageUriResolver userPageUriResolver;

  final bool commentTimeFormatElapsed;

  final double commentTableRowHeight;
  final double commentTableNoWidth;
  final double commentTableUserIconWidth;
  final double commentTableUserNameWidth;
  final double commentTableTimeWidth;

  const NiconicoLiveCommentList({
    super.key,
    required this.chatMessageListScrollController,
    required this.liveBeginDateTime,
    required this.chatMessages,
    required this.userLocalCachedIconImageFileResolver,
    required this.userPageUriResolver,
    required this.commentTimeFormatElapsed,
    required this.commentTableRowHeight,
    required this.commentTableNoWidth,
    required this.commentTableUserIconWidth,
    required this.commentTableUserNameWidth,
    required this.commentTableTimeWidth,
  });

  @override
  State<NiconicoLiveCommentList> createState() => _NiconicoLiveCommentListState();
}

class _NiconicoLiveCommentListState extends State<NiconicoLiveCommentList> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView.builder(
          controller: widget.chatMessageListScrollController,
          itemCount: widget.chatMessages.length,
          itemExtent: widget.commentTableRowHeight,
          itemBuilder: (context, index) {
            final chatMessage = widget.chatMessages[index];

            Widget icon = Container();
            if (chatMessage is NormalChatMessage) {
              final userIconCache = chatMessage.commentUser?.userIconCache;
              if (userIconCache != null) {
                final iconBytes = userIconCache.userIcon.iconBytes;

                icon = MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final iconPath = await widget.userLocalCachedIconImageFileResolver.resolveLocalCachedUserIconImageFile(userId: userIconCache.userId);
                      if (iconPath == null) {
                        _logger.warning('User icon path is not found for the user ID = ${userIconCache.userId}');
                        return;
                      }

                      await OpenFilex.open(iconPath.path);
                    },
                    child: Tooltip(
                      message: 'アイコンの画像ファイルを開く',
                      child: Image.memory(iconBytes),
                    ),
                  ),
                );
              }
            }

            Widget name = Container();
            final nickname = chatMessage is NormalChatMessage ? chatMessage.commentUser?.userPageCache?.userPage.nickname : null;
            final userId = chatMessage.chatMessage.userId;

            if (nickname != null) {
              name = Tooltip(
                message: 'ID: $userId',
                  child: SelectableText.rich(
                  TextSpan(
                    text: nickname,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 120, 255)),
                    mouseCursor: SystemMouseCursors.click,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = await widget.userPageUriResolver.resolveUserPageUri(userId: int.parse(userId));

                        if (uri == null) {
                          _logger.warning('User page uri is not found for the user ID = $userId');
                          return;
                        }

                        if (!await launchUrl(uri)) {
                          throw Exception('Failed to open URL: ${uri.toString()}');
                        }
                      },
                  ),
                ),
              );
            } else {
              name = Tooltip(
                message: 'ID: $userId',
                child: SelectableText(userId),
              );
            }

            final commentedAtDateTime = DateTime.fromMicrosecondsSinceEpoch(chatMessage.chatMessage.date * 1000 * 1000 + chatMessage.chatMessage.dateUsec, isUtc: true);
            final commentedAtDuration = Duration(microseconds: commentedAtDateTime.microsecondsSinceEpoch);
            final liveBeginTimeDuration = Duration(microseconds: widget.liveBeginDateTime.microsecondsSinceEpoch);
            final commentedAtElapsed = commentedAtDuration - liveBeginTimeDuration;

            final inHours = commentedAtElapsed.inHours;
            final inMinutes = commentedAtElapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
            final inSeconds = commentedAtElapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

            final commentedAtElapsedText = '$inHours:$inMinutes:$inSeconds';

            final dateTimeFormat = DateFormat('HH:mm:ss');
            final commentedAtDateTimeText = dateTimeFormat.format(commentedAtDateTime.toLocal());

            final fullDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
            final commentedAtFullDateTimeText = fullDateTimeFormat.format(commentedAtDateTime.toLocal());

            final commentedAt = Tooltip(
              message: 'コメントが投稿された時刻: $commentedAtFullDateTimeText\n番組開始からの経過時間: $commentedAtElapsedText',
              child: SelectableText(widget.commentTimeFormatElapsed ? commentedAtElapsedText : commentedAtDateTimeText)
            );

            TextStyle? textStyle;
            if (chatMessage is! NormalChatMessage) {
              // 0x727272
              // 0xFF0033
              textStyle = const TextStyle(color: Color.fromARGB(255, 0xFF, 0x00, 0x33));
            }
            final content = SelectableText(
              chatMessage.chatMessage.content,
              style: textStyle,
            );

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border.all(width: 1.0)),
                    child: SizedBox(
                      width: widget.commentTableNoWidth,
                      child: Container(
                        alignment: Alignment.centerRight, 
                        child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText('${chatMessage.chatMessage.no}')),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border.all(width: 1.0)),
                    child: SizedBox(
                      width: widget.commentTableUserIconWidth,
                      child: icon,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border.all(width: 1.0)),
                    child: SizedBox(
                      width: widget.commentTableUserNameWidth,
                      child: Padding(padding: const EdgeInsets.all(8.0), child: name),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border.all(width: 1.0)),
                    child: SizedBox(
                      width: widget.commentTableTimeWidth,
                      child: Container(alignment: Alignment.center, child: Padding(padding: const EdgeInsets.all(8.0), child: commentedAt)),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: chatMessage.chatMessage.content,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(border: Border.all(width: 1.0)),
                        child: Padding(padding: const EdgeInsets.all(8.0), child: content)
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
