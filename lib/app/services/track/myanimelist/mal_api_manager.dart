import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mangasoup_prototype_3/Services/generator.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_track_result.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_user.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MALManager {
  static const _clientId = "cb25a7db7422802cc9ab6030727c3a16";
  static const redirectUrl = "https://mangasoup.com/";

  static Map<String, dynamic> requestHeader = {
    "Host": "api.myanimelist.net",
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded",
    "X-MAL-Client-ID": _clientId,
    "User-Agent": "MangaSoup/0.0.2"
  };

  static Dio dio = Dio(options);
  static BaseOptions options = BaseOptions(
    headers: requestHeader,
  );

  static String generateOAuthRoute() {
    String uri = "https://myanimelist.net/v1/oauth2/authorize?"
        "response_type=code"
        "&client_id=$_clientId"
        "&code_challenge=${Generator.generatePKCE()}";
    return uri;
  }

  Future<void> codeExchange(String code, String verifier) async {
    final String url = "https://api.myanimelist.net/v2/auth/token";
    final Map<String, dynamic> body = {
      "grant_type": "authorization_code",
      "client_id": _clientId,
      "code_verifier": verifier,
      "code": code,
    };

    try {
      print("trying");
      Response response = await Dio().post(url, data: FormData.fromMap(body));
      print(response.statusCode);

      if (response.data["access_token"] != null) {
        // Success
        SharedPreferences p = await SharedPreferences.getInstance();
        p.setString(PreferenceKeys.MAL_AUTH, jsonEncode(response.data));
        print(response.data);
      }
    } catch (err) {
      print(err);
      if (err is DioError) {
        DioError e = err;
        print(e.response.data);
      }
      throw err;
    }
  }

  refreshToken(String token) async {
    final String url = "https://api.myanimelist.net/v2/auth/token";
    final Map body = {
      "grant_type": "refresh_token",
      "client_id": _clientId,
      "refresh_token": token.trim(),
    };

    Response response = await dio.post(url, data: body);
    print(response.data);
  }

  Future<MALUser> getUserInfo() async {
    final String url = "https://api.myanimelist.net/v2/users/@me";
    SharedPreferences _p = await SharedPreferences.getInstance();
    String raw = _p.getString(PreferenceKeys.MAL_AUTH);
    if (raw != null) {
      String accessToken = jsonDecode(raw)['access_token'];
      Map<String, dynamic> headers = Map.of(requestHeader);
      headers.putIfAbsent("Authorization", () => "Bearer $accessToken");

      Response response =
          await dio.get(url, options: Options(headers: headers));
      print(response.data);
      return MALUser.fromMap(response.data);
    } else
      return null;
  }

  Future<List<MALTrackResult>> queryMAL(String query) async {
    final String url = "https://api.myanimelist.net/v2/manga";
    SharedPreferences _p = await SharedPreferences.getInstance();
    String raw = _p.getString(PreferenceKeys.MAL_AUTH);
    String accessToken = jsonDecode(raw)['access_token'];

    Map<String, dynamic> headers = Map.of(requestHeader);
    headers.putIfAbsent("Authorization", () => "Bearer $accessToken");

    List<MALTrackResult> results = List();
    String fields = 'id,title,main_picture,synopsis,status,num_chapters';
    try {
      Response response = await dio.get(url,
          options: Options(headers: headers),
          queryParameters: {"q": Uri.encodeFull(query), "fields": fields});
      for (Map d in response.data['data']) {
        var c = d['node'];
        results.add(MALTrackResult.fromMap(c));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return results;
  }

  Future<MALDetailedTrackResult> getManga(int id) async {
    final String url = "https://api.myanimelist.net/v2/manga/$id";
    SharedPreferences _p = await SharedPreferences.getInstance();
    String raw = _p.getString(PreferenceKeys.MAL_AUTH);
    String accessToken = jsonDecode(raw)['access_token'];

    Map<String, dynamic> headers = Map.of(requestHeader);
    headers.putIfAbsent("Authorization", () => "Bearer $accessToken");

    MALDetailedTrackResult results;
    String fields = 'id,title,main_picture,status,num_chapters,my_list_status';
    try {
      Response response = await dio.get(url,
          options: Options(headers: headers),
          queryParameters: {"fields": fields});
      results = MALDetailedTrackResult.fromMap(response.data);
      print(response.data);
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return results;
  }

  Future<void> updateTracker(Tracker tracker) async {
    final String url =
        "https://api.myanimelist.net/v2/manga/${tracker.mediaId}/my_list_status";

    SharedPreferences _p = await SharedPreferences.getInstance();
    String raw = _p.getString(PreferenceKeys.MAL_AUTH);
    if (raw != null) {
      String accessToken = jsonDecode(raw)['access_token'];
      Map<String, dynamic> headers = Map.of(requestHeader);
      headers.putIfAbsent("Authorization", () => "Bearer $accessToken");

      try {
        Map<String, dynamic> t = tracker.toMALUpdateFormat();
        print(t);
        await Dio().patch(url,
            data: t,
            options: Options(
                headers: headers,
                contentType: "application/x-www-form-urlencoded"));
        print("done");
      } catch (err) {
        ErrorManager.analyze(err);
      }
    }
  }
}
