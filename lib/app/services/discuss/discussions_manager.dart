import 'package:dio/dio.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionManager {
  static bool _isDev = true;
  static String _productionAddress = "http://topics.mangasoup.net";
  static String _localAddress = "http://127.0.0.1:3000";
  final String _jwt =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMjg5MTMzM2YzY"
      "TQ2ZWE2NGNiNzJiNyIsImlhdCI6MTYxNDkwMDgyMSwiZXhwIjoxNjE0OT"
      "g3MjIxfQ.S9zsSOoYJv6aeVKZsq6Vp5UEOdGckM5E4ZBXetps1j8";

  static String _address() => _isDev ? _localAddress : _productionAddress;

  static BaseOptions _options = BaseOptions(
    baseUrl: _address(),
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);

  /// Get Access Token
  Future<String> getAccessToken() async {
    // Get Access Token

    if (_isDev) return _jwt;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString(PreferenceKeys.MS_ACCESS_TOKEN);

    if (token.isEmpty) throw "Missing MangaSoup Access Token";
    return token;
  }

  /// Get Chapter Comments.
  Future<List<ChapterComment>> getChapterComments(String link, int page) async {
    List<ChapterComment> comments = List();
    try {
      Response response = await _dio.post("/chapter",
          queryParameters: {"page": page, "limit": 30}, data: {"link": link});
      var target = response.data['data']['comments'];
      for (Map map in target) {
        comments.add(ChapterComment.fromMap(map));
      }
    } catch (err, trace) {
      print(err);
      // print(trace);
      throw "ERROR";
    }
    return comments;
  }

  /// Add Chapter Comments.
  Future<ChapterComment> addComment(String body, String chapterLink) async {
    ChapterComment comment;

    try {
      String token = await getAccessToken();
      // Prepare Body
      Map<String, dynamic> content = {
        "content": body,
        "chapter_link": chapterLink,
      };

      // Make Request
      Response response = await _dio.put(
        "/chapter/add",
        data: content,
        options: Options(
          headers: {"x-access-token": token}, // MangaSoup Auth/Access Token.
        ),
      );

      // Model Logic
      var target = response.data['data'];
      if (target != null) {
        comment = ChapterComment.fromMap(target);
      }
    } catch (err, stacktrace) {
      print(err);
      throw "ERROR";
    }

    return comment;
  }
}
