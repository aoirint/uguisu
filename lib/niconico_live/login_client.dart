import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

class NiconicoLoginResult {
  SweetCookieJar cookieJar;
  bool mfaRequired;
  Uri? mfaFormActionUri;

  NiconicoLoginResult({
    required this.cookieJar,
    required this.mfaRequired,
    this.mfaFormActionUri,
  });
}

class NiconicoMfaLoginResult {
  SweetCookieJar cookieJar;

  NiconicoMfaLoginResult({
    required this.cookieJar,
  });
}

class NiconicoLoginClient {
  late Logger logger;

  NiconicoLoginClient() {
    logger = Logger('NiconicoLoginClient');
  }

  Future<NiconicoLoginResult> login({
    required Uri uri, // https://account.nicovideo.jp/login/redirector
    required String mailTel,
    required String password,
    required String userAgent,
  }) async {
    final request = http.Request('POST', uri);
    request.headers.addAll({
      'user-agent': userAgent,
      'content-type': 'application/x-www-form-urlencoded',
    });
    request.followRedirects = false;
    request.bodyFields = {
      'mail_tel': mailTel,
      'password': password,
    };

    final httpClient = http.Client();

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 302) {
      throw Exception('Request failed. Status ${response.statusCode}');
    }

    final cookieJar = SweetCookieJar.from(response: response);

    final location = response.headers['location'];
    if (location == null) {
      throw Exception('Location header must be defined');
    }

    final redirectedToUri = Uri.parse(location);
    if (redirectedToUri.origin != uri.origin) {
      throw Exception('URL origin must be the same between the redirection for security reason');
    }

    if (redirectedToUri.path == '/mfa') {
      // 確認コード

      // TODO: follow redirect to parse body
      // final responseBody = response.body;
      // final document = parse(responseBody);
      // final formElement = document.querySelector('main form');
      // if (formElement == null) {
      //   throw Exception('MFA Form not found');
      // }

      // final formAction = formElement.attributes['action'];
      // if (formAction == null) {
      //   throw Exception('MFA Form action attribute not found');
      // }
      // if (! formAction.startsWith('/mfa')) {
      //   throw Exception('MFA Form action destination is unexpected');
      // }

      // final mfaFormActionUri = redirectedToUri.resolve(formAction);
      final mfaFormActionUri = redirectedToUri;
      if (redirectedToUri.origin != mfaFormActionUri.origin) {
        throw Exception('URL origin must be the same between the redirected uri and the mfa form action uri for security reason');
      }

      return NiconicoLoginResult(cookieJar: cookieJar, mfaRequired: true, mfaFormActionUri: mfaFormActionUri);
    }

    if (redirectedToUri.path == '/') {
      // ログイン成功
      return NiconicoLoginResult(cookieJar: cookieJar, mfaRequired: false);
    }

    throw Exception('Unexpected login response. Login failed.');
  }

  Future<NiconicoMfaLoginResult> mfaLogin({
    required Uri mfaFormActionUri, // https://account.nicovideo.jp/mfa?...
    required SweetCookieJar cookieJar,
    required String otp,
    required bool isMfaTrustedDevice,
    required String deviceName,
    required String userAgent,
  }) async {
    final request = http.Request('POST', mfaFormActionUri);
    request.headers.addAll({
      'user-agent': userAgent,
      'content-type': 'application/x-www-form-urlencoded',
      'cookie': cookieJar.rawData,
    });
    request.followRedirects = false;
    request.bodyFields = {
      'otp': otp,
      'loginBtn': 'ログイン',
      'is_mfa_trusted_device': isMfaTrustedDevice ? 'true' : 'false',
      'device_name': deviceName,
    };

    final httpClient = http.Client();

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // 元のページから動かなければ失敗
      // main form .formError
      // - 確認コードは6桁の数字です
      // - 確認コードが間違っています

      final responseBody = response.body;
      final document = parse(responseBody);
      final formErrorElement = document.querySelector('main form .formError');
      if (formErrorElement == null) {
        throw Exception('MFA Form Error element not found');
      }

      final formErrorText = formErrorElement.text;

      throw Exception('MFA failed. Error text: $formErrorText');
    }

    // 302 Foundが返ってきてリダイレクト
    if (response.statusCode != 302) {
      throw Exception('Request failed. Status ${response.statusCode}');
    }

    final responseCookieJar = SweetCookieJar.from(response: response);

    final location = response.headers['location'];
    if (location == null) {
      throw Exception('Location header must be defined');
    }

    final redirectedToUri = Uri.parse(location);
    if (redirectedToUri.origin != mfaFormActionUri.origin) {
      throw Exception('URL origin must be the same between the redirection for security reason');
    }

    final redirectedToUriParams = redirectedToUri.queryParameters;
    if (redirectedToUriParams.containsKey('error-code')) {
      final errorCode = redirectedToUriParams['error-code'];
      if (errorCode == 'MFA_SESSION_EXPIRED') {
        // 15分間のセッション切れ
        throw Exception('MFA failed by error code: $errorCode');
      }

      throw Exception('MFA failed by unknown error code: $errorCode');
    }

    return NiconicoMfaLoginResult(cookieJar: responseCookieJar);
  }

}
