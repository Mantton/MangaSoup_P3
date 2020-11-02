import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'dart:convert';

import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';

class ApiManager {
  //10.0.2.2 /127.0.0.1  http://10.0.2.2:8080/app/sources?server=live

  static String _devAddress = "https://mangasoup-4500a.uc.r.appspot.com";
  static String _localTesting = "http://10.0.2.2:8080";
  static String _productionAddress =
      "http://mangasoup-env-1.eba-hd2s2exn.us-east-1.elasticbeanstalk.com";
  static BaseOptions _options = BaseOptions(
    // actual route -->
    baseUrl: _devAddress,
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);
  final DexHub dex = DexHub();

  Future<List<HomePage>> getHomePage() async {
    Response response = await _dio.get('/app/homepage');
    List initial = response.data['content'];
    debugPrint(initial.length.toString());
    List<HomePage> pages = [];
    for (int index = 0; index < initial.length; index++) {
      Map test = initial[index];
      pages.add(HomePage.fromMap(test));
    }
    return pages;
  }

  /// ------------- Server Resources
  Future<List<Source>> getServerSources(String server) async {
    Response response = await _dio.get(
      "/app/sources",
      queryParameters: {
        "server": server,
        "vip": "1"
      }, // todo change vip field to vip status
    );

    List resData = response.data['sources'];

    List<Source> sources = [];
    for (int index = 0; index < resData.length; index++) {
      sources.add(Source.fromMap(resData[index]));
    }
    debugPrint("Sources Loaded");
    return sources;
  }

  /// ------------------- COMIC RESOURCES  ---------------------------- ///
  ///
  /// Get All
  Future<List<ComicHighlight>> getAll(
      String source, String sortBy, int page, Map additionalInfo) async {
    if (source == "mangadex") return dex.get(sortBy, page, {}, {});
    Map data = {
      "source": source,
      "page": page,
      "sort_by": sortBy,
      "data": {'language': "english"}
    };
    Response response = await _dio.post("/api/v2/all", data: jsonEncode(data));
    debugPrint(response.request.data.toString());
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /all @$source s/$sortBy");
    return comics;
  }

  /// Get Latest
  Future<List<ComicHighlight>> getLatest(String source, int page) async {
    if (source == "mangadex") return dex.get("0", page, {}, {});

    Map data = {
      "source": source,
      "page": page,
      "data": {'language': "english"}
    };
    Response response = await _dio.post('/api/v2/latest', data: data);
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /latest @$source");
    return comics;
  }

  /// Get Profile
  Future<ComicProfile> getProfile(String source, String link) async {
    if (source == "mangadex") return dex.profile(link);

    Map data = {
      "source": source,
      "link": link,
      "data": {'language': "english"}
    };
    Response response = await _dio.post('/api/v2/profile', data: data);
    debugPrint(
        "Retrieval Complete : /Profile : ${response.data['title']} @$source");

    return ComicProfile.fromMap(response.data);
  }

  /// Get Images
  Future<List> getImages(String source, String link) async {
    Response response = await _dio.get('/api/v2/images',
        queryParameters: {"source": source, "link": link});

    return response.data['images'];
  }
}
