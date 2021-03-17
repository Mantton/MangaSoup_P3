import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/mangasoup_combined_model.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MSCombined {
  static bool _isDev = true;
  static String _productionAddress = "https://topics.mangasoup.net";
  static String _localAddress = "http://127.0.0.1:5500";

  static String _address() => _isDev ? _localAddress : _productionAddress;
  static BaseOptions _options = BaseOptions(
    baseUrl: _address(),
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);

  /// MangaDex Routes
  Future authorizeWithDex(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Map t = await prepareAdditionalInfo("mangadex");

    Map cookies = t['cookies'];
    if (cookies != null) {
      try {
        Response response = await _dio.post("/auth/mdx",
            data: {"md_session": cookies['mangadex_session']});
        Map data = response.data['data'];
        String token = data["access_token"];
        _prefs.setString(PreferenceKeys.MS_T_ACCESS_TOKEN, token);

        await Provider.of<PreferenceProvider>(context, listen: false)
            .setMSUsr(MSUserCombined.fromMap(data));
        print("Authorized");
        return true;
      } catch (err) {
        managerError(err, context);
      }
    } else {
      throw MissingMangaDexSession();
    }
  }

  /// Get Chapter Comments.
  Future<List<ChapterComment>> getChapterComments(
      String link, int page, BuildContext context) async {
    List<ChapterComment> comments = [];
    String token;
    try {
      token = await getAccessToken();
    } catch (err) {
      //do nothing
    }

    try {
      Response response = await _dio.post(
        "/comments",
        queryParameters: {"page": page, "limit": 30},
        data: {"link": link},
        options: Options(
          headers: token != null
              ? {"x-access-token": token}
              : null, // MangaSoup Auth/Access Token.
        ),
      );
      var target = response.data['data']['comments'];
      for (Map map in target) {
        comments.add(ChapterComment.fromMap(map));
      }
    } catch (err, stacktrace) {
      managerError(err, context);
    }
    return comments;
  }

  /// Get Access Token
  Future<String> getAccessToken() async {
    // Get Access Token
    // if (_isDev) return _jwt;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    // await _prefs.remove(PreferenceKeys.MS_T_ACCESS_TOKEN);
    String token = _prefs.getString(PreferenceKeys.MS_T_ACCESS_TOKEN);
    if (token == null || token.isEmpty) throw "MissingMangaSoupAccessToken";
    return token;
  }

  /// Add Chapter Comments.
  Future<ChapterComment> addComment(
      String body, String chapterLink, BuildContext context) async {
    ChapterComment comment;
    String token = await getAccessToken();
    try {
      // Prepare Body
      Map<String, dynamic> content = {
        "content": body,
        "chapter_link": chapterLink,
      };

      // Make Request
      Response response = await _dio.put(
        "/comments/add",
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
      managerError(err, context);
    }

    return comment;
  }

  Future<void> deleteComment(
      ChapterComment comment, BuildContext context) async {
    String token = await getAccessToken();

    try {
      // Make Request
      Response response = await _dio.delete(
        "/comments/${comment.id}",
        options: Options(
          headers: {"x-access-token": token}, // MangaSoup Auth/Access Token.
        ),
      );
    } catch (err) {
      managerError(err, context);
    }
  }

  Future<void> toggleLike(ChapterComment comment, BuildContext context) async {
    String token = await getAccessToken();

    try {
      // Make Request
      Response response = await _dio.get(
        "/comments/like/${comment.id}",
        options: Options(
          headers: {"x-access-token": token}, // MangaSoup Auth/Access Token.
        ),
      );
    } catch (err) {
      managerError(err, context);
    }
  }

  Future<void> logOut(BuildContext context) async {
    String token = await getAccessToken();

    Response r = await _dio.get(
      '/auth/logout',
      options: Options(
        headers: {"x-access-token": token}, // MangaSoup Auth/Access Token.
      ),
    );
    Map data = r.data;
    bool deleteToken = data['delete_token'] ?? false;
    if (deleteToken) {
      SharedPreferences.getInstance().then((value) {
        value.remove(PreferenceKeys.MS_T_ACCESS_TOKEN);
        Provider.of<PreferenceProvider>(context, listen: false).removeMSUser();
      });
    } else {
      throw "Unable to log you out.";
    }
  }

  managerError(var err, BuildContext context) {
    if (err is DioError) {
      if (err.response != null) {
        if (err.response.statusCode == 401 ||
            err.response.statusCode == 403 ||
            err.response.statusCode == 400) {
          Map data = err.response.data;
          // print(data);
          bool deleteToken = data['delete_token'] ?? false;
          if (deleteToken) {
            SharedPreferences.getInstance().then((value) {
              value.remove(PreferenceKeys.MS_T_ACCESS_TOKEN);
              Provider.of<PreferenceProvider>(context, listen: false)
                  .removeMSUser();
            });
          }
          throw "Authorization Failure.";
        } else if (err.response.statusCode == 429) {
          throw "Too many requests!";
        } else if (err.response.statusCode >= 500) {
          throw "MangaSoup Server Error.";
        } else {
          ErrorManager.analyze(err);
        }
      } else
        ErrorManager.analyze(err);
    } else {
      ErrorManager.analyze(err);
    }
  }
}
