import 'dart:io';

import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

String formatCookieJarForRequestHeader(SweetCookieJar cookieJar) {
  List<Cookie> cookies = [];

  for (final name in cookieJar.nameSet) {
    final namedCookies = cookieJar.findAll(name: name);

    Cookie? namedCookie;
    for (final cookie in namedCookies) {
      if (cookie.isEmpty && cookie.isExpired) {
        namedCookie = null;
        continue;
      }
      if (cookie.isExpired) continue;

      namedCookie = cookie; // use last cookie
    }

    if (namedCookie != null) {
      cookies.add(namedCookie);
    }
  }

  return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
}
