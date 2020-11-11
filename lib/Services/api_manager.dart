import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String imgSrcUrl =
      'https://saucenao.com/search.php?db=37&output_type=2&numres=10&api_key=b1e601ed339f1c909df951a2ebfe597671592d90'; // Image Search Link

  /// Get Home Page
  Future<List<HomePage>> getHomePage() async {
    Response response = await _dio.get('/app/homepage');
    List initial = response.data['content'];
    debugPrint(initial.length.toString());
    List<HomePage> pages = [];
    for (int index = 0; index < initial.length; index++) {
      Map test = initial[index];
      pages.add(HomePage.fromMap(test));
    }
    debugPrint("HomePage Loaded");
    return pages;
  }

  /// ------------- Server Resources
  Future<List<Source>> getServerSources(String server) async {
    Response response = await _dio.get(
      "/app/sources/previews",
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

  /// Initialize Source
  Future<Source> initSource(String selector) async {
    Response response = await _dio
        .get("/app/sources/details", queryParameters: {"selector": selector});
    Source src = Source.fromMap(response.data['source']);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (src.settings != null) {
      String encodedSettings =
          preferences.getString("${src.selector}_settings");
      if (encodedSettings == null) {
        debugPrint("Settings for ${src.name} are not initialized, starting...");
        Map defaultSourceSettings = {};
        src.settings.forEach((element) {
          defaultSourceSettings[element['selector']] = element['default'];
        });

        await preferences.setString(
            "${src.selector}_settings", jsonEncode(defaultSourceSettings));
        debugPrint("Default Settings have been initialized");
      }
    } else
      debugPrint("Source has no settings");
    return src;
  }

  /// Prepare Data Variable
  Future<Map> prepareAdditionalInfo(String source) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String sourceSettings = _prefs.get("${source}_settings");
    String sourceCookies = _prefs.getString("${source}_cookies");

    if (sourceCookies == null && sourceSettings == null) {
      return {};
    } else if (sourceSettings != null && sourceCookies == null) {
      Map settings = jsonDecode(sourceSettings);
      print(settings);
      Map generated = Map();
      settings.forEach((key, value) {
        if (value is! List) {
          // is not List
          print(value.runtimeType);
          generated[key] = value['selector'];
        } else {
          generated[key] = value.map((e) => e['selector']).toList();
        }
      });
      return generated;
    } else if (sourceCookies != null && sourceSettings == null) {
      return {"cookies": jsonDecode(sourceCookies)};
    } else {
      Map settings = jsonDecode(sourceSettings);
      Map generated = Map();
      settings.forEach((key, value) {
        generated[key] = value['selector'];
      });
      generated['cookies'] = jsonDecode(sourceCookies);
      return generated;
    }
  }

  /// ------------------- COMIC RESOURCES  ---------------------------- ///
  ///
  /// Get All
  Future<List<ComicHighlight>> getAll(
      String source, String sortBy, int page) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    if (source == "mangadex") return dex.get(sortBy, page, additionalParams);

    Map data = {
      "source": source,
      "page": page,
      "sort_by": sortBy,
      "data": additionalParams
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
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    if (source == "mangadex") return dex.get("0", page, additionalParams);

    Map data = {
      "source": source,
      "page": page,
      "data": additionalParams,
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
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    Map data = {"source": source, "link": link, "data": additionalParams};
    try {
      Response response = await _dio.post('/api/v2/profile', data: data);
      debugPrint(
          "Retrieval Complete : /Profile : ${response.data['title']} @$source");

      return ComicProfile.fromMap(response.data);
    } on DioError catch (e) {
      throw e.response.data['msg'];
    }
  }

  /// Get Images
  Future<List> getImages(String source, String link) async {
    Response response = await _dio.get('/api/v2/images',
        queryParameters: {"source": source, "link": link});

    return response.data['images'];
  }

  /// Get Tags
  Future<List<Tag>> getTags(String source) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    if (source == "mangadex") return dex.getTags();
    Map data = {"source": source, "data": additionalParams};
    Response response = await _dio.post('/api/v2/tags', data: data);
    List dataPoints = response.data['genres'] ?? response.data;
    print(dataPoints);
    List<Tag> tags = [];
    for (int index = 0; index < dataPoints.length; index++) {
      tags.add(Tag.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /Tags @$source");
    return tags;
  }

  /// Get Tag Comics
  Future<List<ComicHighlight>> getTagComics(
      String source, int page, String link, String sort) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    if (source == "mangadex")
      return dex.getTagComics(sort, page, link, additionalParams);

    Map data = {
      "source": source,
      "page": page,
      "link": link,
      "sort_by": sort,
      "data": additionalParams,
    };
    Response response = await _dio.post('/api/v2/tagComics', data: data);
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /tagComics @$source");
    return comics;
  }

  /// Search
  Future<List<ComicHighlight>> search(String source, String query) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    print(additionalParams);
    if (source == "mangadex") return dex.search(query, additionalParams);

    Map data = {
      "source": source,
      "query": query,
      "data": additionalParams,
    };
    Response response = await _dio.post('/api/v2/search', data: data);
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    debugPrint("Retrieval Complete : /search @$source");
    return comics;
  }

  Future<List<ImageSearchResult>> imageSearch(File image) async {
    debugPrint("${image.path}");
    FormData _data = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last)
    });

    Response response = await _dio.post(imgSrcUrl, data: _data);

    List results = response.data['results'];
    List<ImageSearchResult> isrResults = List();
    results.forEach((element) {
      isrResults.add(ImageSearchResult.fromMap(element));
    });

    return isrResults;
  }

  Future<List> getImgurAlbum(String info) async {
    String albumID;

    // Link
    if (info.contains("http")) {
      if (info.endsWith("/")) info = info.substring(0, info.length - 1);
      print(info);
      // get id
      albumID = info.split("/").last;
      print(albumID);
    } else {
      albumID = info;
    }

    // Use Imgur API
    albumID = albumID.trim();
    try {
      Response response = await _dio.get(
        "https://api.imgur.com/3/album/$albumID/images",
        options: Options(
          headers: {"Authorization": "Client-ID d50a5c2ba38acd4"},
        ),
      );
      print((response.data).toString());

      // Process data

      List _imgAttr = response.data['data'];
      List images = [];
      for (int i = 0; i < _imgAttr.length; i++) {
        images.add(_imgAttr[i]["link"]);
      }
      return images;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
