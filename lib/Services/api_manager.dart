import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'dart:convert';

import 'package:mangasoup_prototype_3/Models/Source.dart';

class ApiManager {
  //10.0.2.2 /127.0.0.1  http://10.0.2.2:5000/app/sources?server=live
  static String _devAddress = "https://mangasoup-4500a.uc.r.appspot.com";
  static String _productionAddress =
      "http://mangasoup-env-1.eba-hd2s2exn.us-east-1.elasticbeanstalk.com";
  static BaseOptions _options = BaseOptions(
    // actual route -->
    baseUrl: _devAddress,
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);

  /// ------------- Server Resources
  Future<List<Source>> getServerSources(String server) async {
    Response response = await _dio.get(
      "/app/sources",
      queryParameters: {
        "server": server,
        "vip": "1"
      }, // todo change vip field to vip status
    );

    List resData = response.data['Sources'];

    List<Source> sources = [];
    for (int index = 0; index < resData.length; index++) {
      sources.add(Source.fromMap(resData[index]));
    }
    return sources;
  }

  /// ------------------- COMIC RESOURCES  ---------------------------- ///
  ///
  /// Get All
  Future<List<ComicHighlight>> getAll(
      String source, String sortBy, int page, Map additionalInfo) async {
    debugPrint('Starting');

    Map data = {
      "source": source,
      "page": page,
      "sort_by": sortBy,
      "additional_params": additionalInfo
    };
    Response response = await _dio.post("/api/v1/all", data: jsonEncode(data));

    List dataPoints = response.data['Comics'];
    List<ComicHighlight> comics = [];

    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /all @$source");
    return comics;
  }

  /// Get Latest
  Future<List<ComicHighlight>> getLatest(String source, int page) async {
    Response response = await _dio.get('/api/v1/latest',
        queryParameters: {"source": source, "page": page});
    List dataPoints = response.data['Comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /latest");
    return comics;
  }

  /// Get Profile
  Future<ComicProfile> getProfile(String source, String link) async {
    Response response = await _dio.get('/api/v1/profile',
        queryParameters: {"source": source, "link": link});

    return ComicProfile.fromMap(response.data);
  }

  /// Get Images
  Future<List> getImages(String source, String link) async {
    Response response = await _dio.get('/api/v1/images',
        queryParameters: {"source": source, "link": link});

    return response.data['Images'];
  }
}
