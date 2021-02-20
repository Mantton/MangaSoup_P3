import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class Generator {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String generatePKCE() {
    var code = getRandomString(128);
    var hash = sha256.convert(ascii.encode(code));
    String codeChallenge = base64Url
        .encode(hash.bytes)
        .replaceAll("=", "")
        .replaceAll("+", "-")
        .replaceAll("/", "_");
    return codeChallenge;
  }
}
