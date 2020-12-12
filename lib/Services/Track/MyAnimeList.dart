import 'package:dio/dio.dart';
import 'package:html/parser.dart';

class MyAnimeListManager {
  final Dio _dio = Dio();
  static const CSRF = "csrf_token";

  // Trying to convert some of tachiyomi code dart
  static const String baseUrl = "https://myanimelist.net";
  static const String baseMangaUrl = "$baseUrl/manga/";
  static const String baseModifyListUrl = "$baseUrl/ownlist/manga";
  static const String loginUrl = "$baseUrl/login.php";
  static const String PREFIX_MY = "my:";
  static const String TD = "td";

  Future<String> getCSRF() async {
    String val;

    Response response = await _dio.get(
      loginUrl, //
      // options: Options(headers: headers),
    );

    var document = parse(response.data);

    var test = document.querySelector("meta[name=csrf_token]").attributes;
    print(test);

    return val;
  }
}
