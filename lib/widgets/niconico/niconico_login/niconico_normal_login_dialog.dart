import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/api/niconico/niconico_resolver.dart';
import 'package:uguisu/niconico_live/login_client.dart';

final Logger _logger = Logger('com.aoirint.uguisu.lib.widgets.niconico.niconico_login.NiconicoNormalLogin');

class NiconicoNormalLoginDialog extends StatefulWidget {
  final NiconicoLoginResolver loginResolver;
  final Future<void> Function({required NiconicoLoginResult loginResult}) onLoginResult;

  const NiconicoNormalLoginDialog({
    super.key,
    required this.loginResolver,
    required this.onLoginResult,
  });

  @override
  State<NiconicoNormalLoginDialog> createState() => _NiconicoNormalLoginDialogState();
}

class _NiconicoNormalLoginDialogState extends State<NiconicoNormalLoginDialog> {
  final mailTelTextController = TextEditingController(text: '');
  final passwordTextController = TextEditingController(text: '');

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
                        Navigator.popUntil(context, ModalRoute.withName('/config'));
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ニコニコ動画アカウントにログイン', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: mailTelTextController,
                style: const TextStyle(fontSize: 16.0),
                enabled: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'メールアドレスまたは電話番号',
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: passwordTextController,
                style: const TextStyle(fontSize: 16.0),
                enabled: true,
                maxLines: 1,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'パスワード',
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
                      final mailTel = mailTelTextController.text;
                      final password = passwordTextController.text;

                      final loginResult = await widget.loginResolver.resolveLogin(mailTel: mailTel, password: password);

                      // FIXME: 例外が投げられる実装になっているのを、エラーを表すオブジェクトを返すように変更する
                      if (loginResult == null) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('エラー：ログインできませんでした'),
                              content: const Text('正しい認証情報が入力されているか確認してください。'),
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

                      await widget.onLoginResult(loginResult: loginResult);
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
