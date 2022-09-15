import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:logging/logging.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';
import 'package:uguisu/niconico_live/cookie_util.dart';

class NiconicoLoginResult {
  SweetCookieJar cookieJar;
  String? userId;
  bool mfaRequired;
  Uri? mfaFormActionUri;

  NiconicoLoginResult({
    required this.cookieJar,
    this.userId,
    required this.mfaRequired,
    this.mfaFormActionUri,
  });
}

class NiconicoMfaLoginResult {
  SweetCookieJar cookieJar;
  String userId;

  NiconicoMfaLoginResult({
    required this.cookieJar,
    required this.userId,
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

      return NiconicoLoginResult(cookieJar: cookieJar, userId: null, mfaRequired: true, mfaFormActionUri: mfaFormActionUri);
    }

    if (redirectedToUri.path == '/') {
      // ログイン成功
      // x-niconico-id from /
      final redirectedRequestHeaders = {'user-agent': userAgent};
      redirectedRequestHeaders['cookie'] = formatCookieJarForRequestHeader(cookieJar);

      final redirectedResponse = await http.get(redirectedToUri, headers: redirectedRequestHeaders);
      if (redirectedResponse.statusCode != 200) {
        throw Exception('Redirected request failed. Status ${redirectedResponse.statusCode}');
      }

      var userId = redirectedResponse.headers['x-niconico-id'];
      if (userId == null) {
        throw Exception('Redirected response does not contains x-niconico-id header');
      }

      return NiconicoLoginResult(cookieJar: cookieJar, userId: userId, mfaRequired: false);
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
    final httpClient = http.Client();

    final mfaRequest = http.Request('POST', mfaFormActionUri);
    mfaRequest.headers.addAll({
      'user-agent': userAgent,
      'content-type': 'application/x-www-form-urlencoded',
      'cookie': formatCookieJarForRequestHeader(cookieJar),
    });
    mfaRequest.followRedirects = false;
    mfaRequest.bodyFields = {
      'otp': otp,
      'loginBtn': 'ログイン',
      'is_mfa_trusted_device': isMfaTrustedDevice ? 'true' : 'false',
      'device_name': deviceName,
    };

    final mfaStreamedResponse = await httpClient.send(mfaRequest);
    final mfaResponse = await http.Response.fromStream(mfaStreamedResponse);

    if (mfaResponse.statusCode == 200) {
      // 元のページから動かなければ失敗
      // main form .formError
      // - 確認コードは6桁の数字です
      // - 確認コードが間違っています

      final responseBody = mfaResponse.body;
      final document = parse(responseBody);
      final formErrorElement = document.querySelector('main form .formError');
      if (formErrorElement == null) {
        throw Exception('MFA Form Error element not found');
      }

      final formErrorText = formErrorElement.text;

      throw Exception('MFA failed. Error text: $formErrorText');
    }

    // 302 Foundが返ってきてリダイレクト
    if (mfaResponse.statusCode != 302) {
      throw Exception('Request failed. Status ${mfaResponse.statusCode}');
    }

    final mfaResponseCookieJar = SweetCookieJar.from(response: mfaResponse);

    final mfaLocation = mfaResponse.headers['location'];
    if (mfaLocation == null) {
      throw Exception('Location header must be defined');
    }

    final mfaRedirectedToUri = Uri.parse(mfaLocation);
    if (mfaRedirectedToUri.origin != mfaFormActionUri.origin) {
      throw Exception('URL origin must be the same between the redirection for security reason');
    }

    final mfaRedirectedToUriParams = mfaRedirectedToUri.queryParameters;
    if (mfaRedirectedToUriParams.containsKey('error-code')) {
      final errorCode = mfaRedirectedToUriParams['error-code'];
      if (errorCode == 'MFA_SESSION_EXPIRED') {
        // 15分間のセッション切れ
        throw Exception('MFA failed by error code: $errorCode');
      }

      throw Exception('MFA failed by unknown error code: $errorCode');
    }

    // user_session, user_session_secure from /login/mfa/callback
    final mfaCallbackRequest = http.Request('GET', mfaRedirectedToUri);
    mfaCallbackRequest.headers.addAll({
      'user-agent': userAgent,
      'cookie': formatCookieJarForRequestHeader(cookieJar + mfaResponseCookieJar),
    });
    mfaCallbackRequest.followRedirects = false;

    final mfaCallbackStreamedResponse = await httpClient.send(mfaCallbackRequest);
    final mfaCallbackResponse = await http.Response.fromStream(mfaCallbackStreamedResponse);

    final mfaCallbackResponseCookieJar = SweetCookieJar.from(response: mfaCallbackResponse);
    
    if (mfaCallbackResponse.statusCode != 302) {
      throw Exception('MFA callback failed. Status ${mfaCallbackResponse.statusCode}');
    }

    // ログイン成功
    // x-niconico-id from /
    final mfaCallbackLocation = mfaCallbackResponse.headers['location'];
    if (mfaCallbackLocation == null) {
      throw Exception('Location header must be defined');
    }

    final mfaCallbackRedirectedToUri = Uri.parse(mfaCallbackLocation);
    // TODO: check redirection to uri origin

    final mfaCallbackRedirectedRequestHeaders = {'user-agent': userAgent};
    mfaCallbackRedirectedRequestHeaders['cookie'] = formatCookieJarForRequestHeader(cookieJar + mfaResponseCookieJar + mfaCallbackResponseCookieJar);

    final mfaCallbackRedirectedResponse = await http.get(mfaCallbackRedirectedToUri, headers: mfaCallbackRedirectedRequestHeaders);
    if (mfaCallbackRedirectedResponse.statusCode != 200) {
      throw Exception('MFA callback redirected request failed. Status ${mfaCallbackRedirectedResponse.statusCode}');
    }

    var userId = mfaCallbackRedirectedResponse.headers['x-niconico-id'];
    if (userId == null) {
      throw Exception('MFA callback redirected response does not contains x-niconico-id header');
    }

    // TODO: normalize cookies
    return NiconicoMfaLoginResult(cookieJar: cookieJar + mfaResponseCookieJar + mfaCallbackResponseCookieJar, userId: userId);
    // return NiconicoMfaLoginResult(cookieJar: responseCookieJar);
  }

}
