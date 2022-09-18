import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/api/niconico/niconico_resolver.dart';
import 'package:uguisu/niconico_live/login_client.dart';

final Logger _logger = Logger('com.aoirint.uguisu.lib.widgets.niconico.niconico_login.NiconicoMfaLoginDialog');

class NiconicoMfaLoginDialog extends StatefulWidget {
  final Future<void> Function() onPressedBackButton;
  final NiconicoMfaLoginResolver mfaLoginResolver;
  final Future<void> Function({required NiconicoMfaLoginResult mfaLoginResult}) onMfaLoginResult;

  const NiconicoMfaLoginDialog({
    super.key,
    required this.onPressedBackButton,
    required this.mfaLoginResolver,
    required this.onMfaLoginResult,
  });

  @override
  State<NiconicoMfaLoginDialog> createState() => _NiconicoMfaLoginDialogState();
}

class _NiconicoMfaLoginDialogState extends State<NiconicoMfaLoginDialog> {
  final otpTextController = TextEditingController(text: '');
  final deviceNameTextController = TextEditingController(text: 'Uguisu');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tooltip(
                    message: '前の画面に戻る',
                    child: ElevatedButton(
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.arrow_back),
                      ),
                      onPressed: () async {
                        otpTextController.clear();
                        deviceNameTextController.clear();

                        await widget.onPressedBackButton();
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('確認コードの入力', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: otpTextController,
                style: const TextStyle(fontSize: 16.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: '確認コード',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: deviceNameTextController,
                style: const TextStyle(fontSize: 16.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'デバイス名',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('ログイン', style: TextStyle(fontSize: 16.0)),
                    ),
                    onPressed: () async {
                      const userAgent = 'uguisu/0.0.0';
                      final otp = otpTextController.text;
                      final deviceName = deviceNameTextController.text;

                      final mfaLoginResult = await widget.mfaLoginResolver.resolveMfaLogin(otp: otp, deviceName: deviceName);

                      // FIXME: 例外が投げられる実装になっているのを、エラーを表すオブジェクトを返すように変更する
                      if (mfaLoginResult == null) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('エラー：ログインできませんでした'),
                              content: const Text('正しい確認コードが入力されているか確認してください。'),
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

                      otpTextController.clear();
                      deviceNameTextController.clear();

                      await widget.onMfaLoginResult(mfaLoginResult: mfaLoginResult);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
