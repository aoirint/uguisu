import 'package:flutter/material.dart';
import 'package:uguisu/api/niconico/niconico_resolver.dart';

class NiconicoLiveConnectForm extends StatelessWidget {
  final TextEditingController liveIdOrUrlTextController;
  final NiconicoLivePageUriResolver livePageUriResolver;
  final Future<void> Function({required Uri livePageUri}) onSubmitLivePageUri;

  const NiconicoLiveConnectForm({
    super.key,
    required this.liveIdOrUrlTextController,
    required this.livePageUriResolver,
    required this.onSubmitLivePageUri,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0), 
            child: TextField(
              controller: liveIdOrUrlTextController,
              style: const TextStyle(fontSize: 12.0),
              enabled: true,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'ニコニコ生放送 番組ID または URL (例: lv000000000, https://live.nicovideo.jp/watch/lv000000000)',
                contentPadding: EdgeInsets.all(4.0),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), 
          child: Tooltip(
            message: '番組に接続',
            child: ElevatedButton(
              onPressed: () {
                Future(() async {
                  final livePageUri = await livePageUriResolver.resolveLivePageUri(liveIdOrUrl: liveIdOrUrlTextController.text);
                  if (livePageUri == null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text('エラー：入力された番組IDまたはURLの形式は非対応です'),
                          content: const Text('正しい形式で入力されているか確認してください。'),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    return;
                  }

                  await onSubmitLivePageUri(livePageUri: livePageUri);
                });
              },
              child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.power)),
            ),
          ),
        ),
      ],
    );
  }
}
