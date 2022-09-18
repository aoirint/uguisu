import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uguisu/api/niconico/niconico_resolver.dart';
import 'package:uguisu/niconico_live/login_client.dart';
import 'package:uguisu/widgets/niconico/niconico.dart';

final Logger _logger = Logger('com.aoirint.uguisu.lib.widgets.niconico.niconico_login.NiconicoLoginSwitchDialog');

class NiconicoLoginSwitchDialog extends StatefulWidget {
  final NiconicoLoginResolver loginResolver;
  final NiconicoMfaLoginResolver Function({required NiconicoLoginResult loginResult}) mfaLoginResolverBuilder;
  final Future<void> Function({required NiconicoLoginResult loginResult}) onLoginResult;
  final Future<void> Function({required NiconicoMfaLoginResult mfaLoginResult}) onMfaLoginResult;

  const NiconicoLoginSwitchDialog({
    super.key,
    required this.loginResolver,
    required this.mfaLoginResolverBuilder,
    required this.onLoginResult,
    required this.onMfaLoginResult,
  });

  @override
  State<NiconicoLoginSwitchDialog> createState() => _NiconicoLoginSwitchDialogState();
}

class _NiconicoLoginSwitchDialogState extends State<NiconicoLoginSwitchDialog> {
  NiconicoLoginResult? loginResult;
  NiconicoMfaLoginResult? mfaLoginResult;

  @override
  Widget build(BuildContext context) {
    if (loginResult == null) {
      return NiconicoNormalLoginDialog(
        loginResolver: widget.loginResolver,
        onLoginResult: ({required loginResult}) async {
          setState(() {
            this.loginResult = loginResult;
          });
        },
      );
    }

    if (! loginResult!.mfaRequired) {
      Future(() async {
        await widget.onLoginResult.call(loginResult: loginResult!);
      });
      return Column();
    }

    if (mfaLoginResult == null) {
      return NiconicoMfaLoginDialog(
        onPressedBackButton: () async {
          setState(() {
            loginResult = null;
          });
        },
        mfaLoginResolver: widget.mfaLoginResolverBuilder.call(loginResult: loginResult!),
        onMfaLoginResult: ({required mfaLoginResult}) async {
          setState(() {
            this.mfaLoginResult = mfaLoginResult;
          });
        },
      );
    }

    Future(() async {
      await widget.onMfaLoginResult.call(mfaLoginResult: mfaLoginResult!);
    });
    return Column();
  }
}
