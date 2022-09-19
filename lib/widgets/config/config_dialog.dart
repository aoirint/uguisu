import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/api/niconico/niconico.dart';
import 'package:uguisu/main.dart';
import 'package:url_launcher/url_launcher.dart';

final Logger _logger = Logger('com.aoirint.uguisu.lib.widgets.config.ConfigDialog');

class Config {
  double windowOpacity;
  bool alwaysOnTop;
  bool commentTimeFormatElapsed;

  Config({
    required this.windowOpacity,
    required this.alwaysOnTop,
    required this.commentTimeFormatElapsed,
  });
}

class ConfigDialog extends StatelessWidget {
  final NiconicoLoginCookie? loginCookie;
  final NiconicoLoginUser? loginUser;
  final NiconicoUserPageUriResolver userPageUriResolver;
  final Config config;

  final Future<void> Function({required Config config}) onChanged;

  const ConfigDialog({
    super.key,
    this.loginCookie,
    this.loginUser,
    required this.userPageUriResolver,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Future(() async {
    //   setState(() {
    //     windowOpacityValue = sharedPreferences!.getDouble('windowOpacity') ?? windowOpacityDefaultValue;
    //     alwaysOnTopValue = sharedPreferences!.getBool('alwaysOnTop') ?? alwaysOnTopDefaultValue;
    //     commentTimeFormatElapsedValue = sharedPreferences!.getBool('commentTimeFormatElapsed') ?? commentTimeFormatElapsedDefaultValue;
    //   });
    // });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('設定', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('ログイン', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Tooltip(
                    message: 'ニコニコ動画アカウントにログイン',
                    child: ElevatedButton(
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text('ニコニコ動画'),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, '/config/login');
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  loginCookie != null ?
                    const Tooltip(message: 'ログイン済み', child: Icon(Icons.done)) : 
                    Column(),
                  const SizedBox(width: 8.0),
                  loginUser == null ? Column() : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        final uri = await userPageUriResolver.resolveUserPageUri(userId: loginUser!.loginUserPageCache.userId);
  
                        if (uri == null) {
                          _logger.warning('User page uri is not found for the user ID = ${loginUser!.loginUserPageCache.userId}');
                          return;
                        }

                        if (!await launchUrl(uri)) {
                          throw Exception('Failed to open URL: ${uri.toString()}');
                        }
                      },
                      child: Tooltip(
                        message: 'ユーザーページを開く',
                        child: Row(
                          children: [
                            SizedBox(width: 32.0, height: 32.0, child: Image.memory(loginUser!.loginUserIconCache.userIcon.iconBytes)),
                            const SizedBox(width: 8.0),
                            Text('${loginUser!.loginUserPageCache.userPage.nickname} (ID: ${loginUser!.loginUserPageCache.userId})'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('表示', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('ウインドウの不透明度'),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      min: 0.25,
                      max: 1.0,
                      divisions: 100,
                      value: config.windowOpacity,
                      onChanged: (newValue) {
                        config.windowOpacity = newValue;
                        onChanged.call(config: config);
                      },
                    ),
                  ),
                  Text('${(config.windowOpacity * 100).floor()} %'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('常に手前に表示'),
                  Switch(
                    value: config.alwaysOnTop,
                    onChanged: (newValue) {
                      config.alwaysOnTop = newValue;
                      onChanged.call(config: config);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('コメント投稿時間を番組経過時間で表示'),
                  Switch(
                    value: config.commentTimeFormatElapsed,
                    onChanged: (newValue) {
                      config.commentTimeFormatElapsed = newValue;
                      onChanged.call(config: config);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
