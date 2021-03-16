import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/homepage.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/language_server.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:mangasoup_prototype_3/app/data/enums/comic_status.dart';
import 'package:mangasoup_prototype_3/app/data/mangadex/models/mangadex_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiManager {
  static String _devAddress = "http://api.mangasoup.net";
  static String _localAddress = "http://127.0.0.1:5000";

  static BaseOptions _options = BaseOptions(
    baseUrl: _devAddress,
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );

  static BaseOptions _download = BaseOptions(
    baseUrl: _devAddress,
    connectTimeout: 5000,
    receiveTimeout: 5000,
  );
  final Dio _dio = Dio(_options);
  final DexHub dex = DexHub();
  final String imgSrcUrl = 'https://saucenao.com/search.php?db=37'
      '&output_type=2'
      '&numres=10'
      '&api_key=b1e601ed339f1c909df951a2ebfe597671592d90'; // Image Search Link

  /// Get Home Page

  /// ------------- Server Resources
  Future<List<Source>> getServerSources(String server) async {
    Response response = await _dio.get(
      "/app/sources/previews",
      queryParameters: {"server": server, "hentai": "1"},
    );

    List resData = response.data['sources'];

    List<Source> sources = [];
    for (int index = 0; index < resData.length; index++) {
      sources.add(Source.fromMap(resData[index]));
    }
    debugPrint("Sources Loaded");
    return sources;
  }

  Future<List<LanguageServer>> getLanguageServers() async {
    List<LanguageServer> servers = [];
    try {
      Response response = await _dio.get("/app/sources/servers");

      for (var map in response.data['data']) {
        servers.add(LanguageServer.fromMap(map));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }

    return servers;
  }

  Future<List<HomePage>> getHomePage() async {
    Response response = await _dio.get('/app/sources/homepage');
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

        /// Initialize Default Settings
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

  /// ------------------- COMIC RESOURCES  ---------------------------- ///
  ///
  /// Get All
  Future<List<ComicHighlight>> getAll(
      String source, String sortBy, int page) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    if (source == "mangadex") return dex.get(sortBy, page, additionalParams);

    Map data = {
      "selector": source,
      "page": page,
      "sort_by": sortBy,
      "data": additionalParams
    };
    Response response = await _dio.post("/api/v1/all", data: jsonEncode(data));
    debugPrint(response.request.data.toString());
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    return comics;
  }

  /// Get Latest
  Future<List<ComicHighlight>> getLatest(String source, int page) async {
    Map additionalParams = await prepareAdditionalInfo(source);
    if (source == "mangadex") return dex.get("0", page, additionalParams);

    Map data = {
      "selector": source,
      "page": page,
      "data": additionalParams,
    };
    Response response = await _dio.post('/api/v1/latest', data: data);
    List dataPoints = response.data['comics'];
    List<ComicHighlight> comics = [];
    for (int index = 0; index < dataPoints.length; index++) {
      comics.add(ComicHighlight.fromMap(dataPoints[index]));
    }
    return comics;
  }

  /// Get Profile
  Future<Profile> getProfile(String source, String link) async {
    Profile p;
    try {
      Map additionalParams = await prepareAdditionalInfo(source);
      if (source == "mangadex") return dex.profile(link, additionalParams);
      Map data = {"selector": source, "link": link, "data": additionalParams};
      Response response = await _dio.post('/api/v1/profile', data: data);
      p = Profile.fromMap(response.data);
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return p;
  }

  /// Get Images
  Future<ImageChapter> getImages(String source, String link) async {
    ImageChapter chapter;
    try {
      Map additionalParams = await prepareAdditionalInfo(source);
      if (source == "mangadex") return dex.images(link, additionalParams);

      Map data = {
        "selector": source,
        "link": link,
        "data": additionalParams,
      };
      Response response = await _dio.post('/api/v1/images', data: data);
      chapter = ImageChapter.fromMap(response.data);
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return chapter;
  }

  /// Get Tags
  Future<List<Tag>> getTags(String source) async {
    List<Tag> tags = List();
    try {
      Map additionalParams = await prepareAdditionalInfo(source);
      if (source == "mangadex") return dex.getTags();
      Map data = {"selector": source, "data": additionalParams};
      Response response = await _dio.post('/api/v1/tags', data: data);
      List dataPoints = response.data['genres'] ?? response.data;
      for (int index = 0; index < dataPoints.length; index++) {
        tags.add(Tag.fromMap(dataPoints[index]));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return tags;
  }

  /// Get Tag Comics
  Future<List<ComicHighlight>> getTagComics(
      String source, int page, String link, String sort) async {
    List<ComicHighlight> comics = List();

    try {
      Map additionalParams = await prepareAdditionalInfo(source);
      if (source == "mangadex")
        return dex.getTagComics(sort, page, link, additionalParams);

      Map data = {
        "selector": source,
        "page": page,
        "link": link,
        "sort_by": sort,
        "data": additionalParams,
      };
      Response response = await _dio.post('/api/v1/tag-comics', data: data);
      List dataPoints = response.data['comics'];
      for (int index = 0; index < dataPoints.length; index++) {
        comics.add(ComicHighlight.fromMap(dataPoints[index]));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return comics;
  }

  /// Search
  Future<List<ComicHighlight>> search(String source, String query) async {
    List<ComicHighlight> comics = List();

    try {
      Map additionalParams = await prepareAdditionalInfo(source);

      if (source == "mangadex") return dex.search(query, additionalParams);

      Map data = {
        "selector": source,
        "query": query,
        "data": additionalParams,
      };
      Response response = await _dio.post('/api/v1/search', data: data);
      List dataPoints = response.data['comics'] ?? [];
      for (int index = 0; index < dataPoints.length; index++) {
        comics.add(ComicHighlight.fromMap(dataPoints[index]));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return comics;
  }

  Future<List<ComicHighlight>> browse(String source, Map query) async {
    List<ComicHighlight> comics = List();

    try {
      Map additionalParams = await prepareAdditionalInfo(source);
      if (source == "mangadex") return dex.browse(query, additionalParams);
      additionalParams.addAll(query);
      Map data = {
        "selector": source,
        "data": additionalParams,
      };
      Response response = await _dio.post('/api/v1/browse', data: data);
      List dataPoints = response.data['comics'];
      for (int index = 0; index < dataPoints.length; index++) {
        comics.add(ComicHighlight.fromMap(dataPoints[index]));
      }
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return comics;
  }

  Future<DexProfile> getMangadexProfile() async {
    Map additionalParams = await prepareAdditionalInfo("mangadex");
    return DexHub().setUserProfile(additionalParams);
  }

  Future<List<ComicHighlight>> getMangaDexUserLibrary() async {
    Map additionalParams = await prepareAdditionalInfo("mangadex");
    return DexHub().getUserLibrary(additionalParams);
  }

  Future<void> syncChapters(List<String> links, bool read) async {
    Map additionalParams = await prepareAdditionalInfo("mangadex");
    List<int> ids = List();
    try {
      for (String link in links) {
        String target = link.split("/").last;
        ids.add(int.parse(target));
      }
      await DexHub().markChapter(ids, read, additionalParams);
    } catch (e) {
      print(e.response.data);
      throw "Chapter Sync Error";
    }
  }

  Future<List<ImageSearchResult>> imageSearch(File image) async {
    List<ImageSearchResult> isrResults = List();

    try {
      debugPrint("${image.path}");
      FormData _data = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path,
            filename: image.path.split('/').last)
      });

      Response response = await _dio.post(imgSrcUrl, data: _data);

      List results = response.data['results'];
      results.forEach((element) {
        isrResults.add(ImageSearchResult.fromMap(element));
      });
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return isrResults;
  }

  Future<Map> getImgurAlbum(String info) async {
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
      Response albumDetails = await _dio.get(
        "https://api.imgur.com/3/album/$albumID",
        options: Options(
          headers: {"Authorization": "Client-ID d50a5c2ba38acd4"},
        ),
      );
      String title = albumDetails.data["data"]['title'];
      List images = [];

      for (Map map in albumDetails.data['data']['images']) {
        images.add(map['link']);
      }

      // Process data
      return {
        "title": title,
        "images": images,
        "link": "https://api.imgur.com/3/album/$albumID"
      };
    } catch (e) {
      print(e);
      return {"title": "", "images": []};
    }
  }
}

/// Prepare Data Variable
Future<Map> prepareAdditionalInfo(String source) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String sourceSettings = _prefs.get("${source}_settings");
  String sourceCookies = _prefs.getString("${source}_cookies");

  if (sourceCookies == null && sourceSettings == null) {
    return {};
  } else {
    Map generated = Map();

    if (sourceSettings != null) {
      /// Prepare Settings
      Map settings = jsonDecode(sourceSettings); // Decode Settings
      settings.forEach((key, value) {
        if (value is! List) {
          // is not List
          generated[key] = value['selector'];
        } else {
          generated[key] =
              value.map((e) => e['selector']).toList(); // Iterate if list
        }
      });
    }

    /// Prepare Cookies
    if (sourceCookies != null) {
      generated['cookies'] = jsonDecode(sourceCookies);
    }

    // print("DATA: $generated");
    return generated;
  }
}

Status statusLogic(String status) {
  int index = 0;
  try {
    index = int.parse(status);
  } catch (err) {}
  return Status.values[index];
}
