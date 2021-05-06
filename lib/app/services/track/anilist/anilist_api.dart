import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_user.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/screens/track/anilist/track_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AniList {
  static const secret = 'KWNihFPEvDleBGJa387Lt21M8eiKa6ldy9juNy7B';
  static const id = '5498';
  final apiUrl = 'https://graphql.anilist.co';

  static String loginAddress() =>
      'https://anilist.co/api/v2/oauth/authorize?client_id=$id&response_type=token';

  static Map<String, dynamic> requestHeader = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    "User-Agent": "MangaSoup-Client"
  };

  saveUser(String token) async {
    SharedPreferences p = await SharedPreferences.getInstance();
    p.setString(PreferenceKeys.ANILIST_ACCESS_TOKEN, token);
  }

  deleteUser() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    p.remove(PreferenceKeys.ANILIST_ACCESS_TOKEN);
    p.remove(PreferenceKeys.ANILIST_USER_ID);
  }

  Future<AniListUser> getCurrentUser() async {
    String query = """
            query User {
                Viewer {
                    id
                    name
                    about
                    avatar {
                        large
                    }
                    statistics {
                        manga {
                            count
                            meanScore
                            chaptersRead
                            volumesRead
                        }    
                    }
                    mediaListOptions {
                        scoreFormat
                    }
                }
            }
            """;
    Response response;
    try {
      SharedPreferences _p = await SharedPreferences.getInstance();
      String token = _p.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN);

      if (token.contains('&')) {
        token = token.split('&').first;
        _p.setString(PreferenceKeys.ANILIST_ACCESS_TOKEN, token);
      }
      if (token != null) {
        Map<String, dynamic> headers = Map.of(requestHeader);
        headers.putIfAbsent("Authorization", () => "Bearer $token");
        response = await Dio().post(apiUrl,
            data: jsonEncode({'query': query}),
            options: Options(headers: headers));
        var data = response.data['data']['Viewer'];
        var x = AniListUser.fromMap(data);
        _p.setInt(PreferenceKeys.ANILIST_USER_ID, x.id);
        return x;
      } else
        return null;
    } catch (err) {
      // print(err.response.data);
      ErrorManager.analyze(err);
    }
    return null;
  }

  Future<List<AniListResult>> queryAnilist(String title) async {
    var query = """
            |query Search(\$query : String) {
                |Page (perPage: 50) {
                    |media(search: \$query, type: MANGA, format_not_in: [NOVEL]) {
                        |id
                        |title {
                            |romaji
                        |}
                        |coverImage {
                            |large
                        |}
                        |type
                        |status
                        |chapters
                        |description
                        |startDate {
                            |year
                            |month
                            |day
                        |}
                    |}
                |}
            |}
            |"""
        .replaceAll('|', '');

    Response response;
    try {
      SharedPreferences _p = await SharedPreferences.getInstance();
      String token = _p.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN);
      if (token != null) {
        Map<String, dynamic> headers = Map.of(requestHeader);
        headers.putIfAbsent("Authorization", () => "Bearer $token");
        var variables = {'query': title};
        response = await Dio().post(apiUrl,
            data: jsonEncode({'query': query, "variables": variables}),
            options: Options(headers: headers));
        List<AniListResult> results = [];
        for (Map t in response.data['data']['Page']['media']) {
          results.add(AniListResult.fromMap(t));
        }

        return results;
      } else
        return null;
    } catch (err) {
      // print(err.response.data);
      ErrorManager.analyze(err);
    }
    return null;
  }

  Future<AnilistDetailedResponse> getLibraryManga(int mangaId) async {
    var query = """
            |query (\$idd: Int!, \$manga_id: Int!) {
                |Page {
                    |mediaList(userId: \$idd, type: MANGA, mediaId: \$manga_id) {
                        |id
                        |status
                        |scoreRaw: score(format: POINT_100)
                        |progress
                        |startedAt {
                            |year
                            |month
                            |day
                        |}
                        |completedAt {
                            |year
                            |month
                            |day
                        |}
                        |media {
                            |id
                            |title {
                                |romaji
                            |}
                            |coverImage {
                                |large
                            |}
                            |type
                            |status
                            |chapters
                            |startDate {
                                |year
                                |month
                                |day
                            |}
                        |}
                    |}
                |}
            |}
            |"""
        .replaceAll('|', '');

    Response response;
    try {
      SharedPreferences _p = await SharedPreferences.getInstance();
      String token = _p.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN);
      int id = _p.getInt(PreferenceKeys.ANILIST_USER_ID);
      if (token != null) {
        Map<String, dynamic> headers = Map.of(requestHeader);
        headers.putIfAbsent("Authorization", () => "Bearer $token");
        var variables = {'idd': id, "manga_id": mangaId};
        response = await Dio().post(apiUrl,
            data: jsonEncode({'query': query, "variables": variables}),
            options: Options(headers: headers));

        // print(response.data);
        List result = response.data['data']['Page']['mediaList'];
        // print(result[0]);
        if (result.isNotEmpty) {
          var x = AnilistDetailedResponse.fromMap(result[0]);
          return x;
        } else {
          addManga(mangaId).then((value) => getLibraryManga(mangaId));
        }
      } else
        return null;
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return null;
  }

  Future<void> addManga(int mangaId) async {
    var query = """
            |mutation AddManga(\$mangaId: Int, \$status: MediaListStatus) {
                |SaveMediaListEntry (mediaId: \$mangaId, status:\$status) { 
                |   id 
                |   status 
                |} 
            |}
            |"""
        .replaceAll('|', '');

    Response response;
    try {
      SharedPreferences _p = await SharedPreferences.getInstance();
      String token = _p.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN);
      int id = _p.getInt(PreferenceKeys.ANILIST_USER_ID);
      if (token != null) {
        Map<String, dynamic> headers = Map.of(requestHeader);
        headers.putIfAbsent("Authorization", () => "Bearer $token");
        var variables = {"mangaId": mangaId, 'status': "CURRENT"};
        response = await Dio().post(apiUrl,
            data: jsonEncode({'query': query, "variables": variables}),
            options: Options(headers: headers));

        // print(response.data);
      } else
        return null;
    } catch (err) {
      // print(err.response.data);
      ErrorManager.analyze(err);
    }
  }

  Future<void> updateTracker(Tracker tracker) async {
    var query = """
            |mutation UpdateManga(
                |\$listId: Int, \$progress: Int, \$status: MediaListStatus,
                |\$score: Int
            |) {
                |SaveMediaListEntry(
                    |id: \$listId, progress: \$progress, status: \$status,
                    |scoreRaw: \$score
                |) {
                    |id
                    |status
                    |progress
                    |score
                |}
            |}
            |"""
        .replaceAll('|', '');
    Response response;
    try {
      SharedPreferences _p = await SharedPreferences.getInstance();
      String token = _p.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN);
      int id = _p.getInt(PreferenceKeys.ANILIST_USER_ID);
      if (token != null) {
        Map<String, dynamic> headers = Map.of(requestHeader);
        headers.putIfAbsent(
            "Authorization", () => "Bearer ${token.split('&').first}");
        var variables = {
          "listId": tracker.syncId,
          'status': getAnilistStatusString(tracker.status),
          'progress': tracker.lastChapterRead,
          'score': tracker.score * 10
        };
        response = await Dio().post(apiUrl,
            data: jsonEncode({'query': query, "variables": variables}),
            options: Options(headers: headers));

        // print(response.data);
      } else
        return null;
    } catch (err) {
      // print(err.response.data);
      ErrorManager.analyze(err);
    }
  }
}
