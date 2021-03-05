import 'package:dio/dio.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';

class DiscussionManager {
  /// This is a development test version of the Wrapper, things like auth have not been implemented
  static String _devAddress = "http://34.70.145.22";
  static String _localAddress = "http://127.0.0.1:3000";
  final String _jwt =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMjg5MTMzM2YzY"
      "TQ2ZWE2NGNiNzJiNyIsImlhdCI6MTYxNDkwMDgyMSwiZXhwIjoxNjE0OT"
      "g3MjIxfQ.S9zsSOoYJv6aeVKZsq6Vp5UEOdGckM5E4ZBXetps1j8";

  static BaseOptions _options = BaseOptions(
    baseUrl: _localAddress,
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);

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
}
