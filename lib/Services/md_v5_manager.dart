import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';

class MangaDexV5 {
  /* Holds the tags uuid for the new API*/
  final Map tagsDict = {};
  final String baseURL = "https://mangadex.org";
  final String apiURL = "https://api.mangadex.org";
  final String temporaryThumbnail = 'https://i.imgur.com/6TrIues.jpg';
  static String selector = "md-v5";
  static String source = "MangaDex V5";
  final Map langMapping = {
    'en': 'gb',
    'pt-br': 'pt',
    'ru': 'ru',
    'fr': 'fr',
    'es-la': 'es',
    'pl': 'pl',
    'tr': 'tr',
    'it': 'it',
    'es': 'es',
    'id': 'id',
    'vi': 'vn',
    'hu': 'hu',
    'zh': 'cn',
    'ar': 'sa', // Arabic
    'de': 'de',
    'zh-hk': 'hk',
    'ca': 'ct', // Catalan
    'th': 'th',
    'bg': 'bg',
    'uk': 'ua',
    'mn': 'mn',
    'he': 'il', // Hebrew
    'ro': 'ro',
    'ms': 'my',
    'tl': 'th', // Tagalog
    'ja': 'jp',
    'ko': 'kr',
    'hi': 'in', // Hindi
    'my': 'my', // Malaysian
    'cs': 'cz',
    'pt': 'pt',
    'nl': 'nl',
    'sv': 'se', // Swedish
    'bn': 'bd', // Bengali
    'no': 'no',
    'lt': 'lt',
    // 'sr': '', // Serbian
    'da': 'dk',
    'fi': 'fi',
  };

  /// Profile Related.
  // GET Manga Profile
  Future<Profile> profile(String id, Map info) async {
    Dio _dio = Dio();
    Response response;
    Response chapterResponse;
    debugPrint(id);

    try {
      // Profile Details
      response = await _dio.get(apiURL + '/manga/$id');
      // Chapter Details

    } catch (err) {
      debugPrint("MangaDex API Error: GET Profile");
      throw "Failed to reach MangaDex V5 API.";
    }

    Map manga = Map();

    try {
      manga = response.data['data']['attributes'];
    } catch (err) {
      throw "MangaDex V5 API Schema Changed.";
    }

    // Parse
    var title = manga['title']['en'];

    var titles = manga['altTitles'].map((e) => e).toList();
    // print(titles);
    var summary = manga['description']['en'];
    var status = parseStatus(manga['status']).toString();

    /* Change when the api contains attributes for these */
    var artist = '';
    var author = '';

    List genres = manga['tags'];
    List tags = [];
    for (Map t in genres) {
      var id = t['id'];
      var name = t['attributes']['name']['en'];

      tags.add({"tag": name, "link": id, "selector": selector});
    }

    int page = 1;
    List chapterList = [];
    List results = [];
    var contentLang = info['contentLang'];

    while (chapterResponse?.statusCode != 204) {
      print(page);
      chapterResponse = await _dio.get(apiURL + '/manga/$id/feed/',
          queryParameters: {
            'limit': 500,
            'offset': 100 * (page - 1),
            'locales[]': contentLang
          });
      page++;

      if (chapterResponse.statusCode != 204) {
        results = chapterResponse.data['results'];

        if (results.isEmpty) break;

        for (Map result in results) {
          var r = result['data'];
          var id = r['id'];
          var attributes = r['attributes'];
          var volume = attributes['volume'];
          var chapter = attributes['chapter'];
          String rawLang = attributes['translatedLanguage'];
          var language = langMapping[rawLang];
          var title = attributes['title'];

          var finalTitle =
              "${(volume != null) ? "Vol. $volume" : ""} Ch. ${chapter.isNotEmpty ? chapter : results.indexOf(result)} ";

          var formattedDate = DateFormat.yMMMd()
              .format(DateTime.parse(attributes['publishAt']));
          chapterList.add({
            "name": finalTitle,
            "link": id,
            "date": formattedDate,
            "maker":
                "${language != null ? emoji(language) : rawLang.toUpperCase()}"
            // "maker": "${_emoji(lang)} - $groupName"
          });
        }
      }
    }

    Map<String, dynamic> x = {
      "title": HtmlUnescape().convert(title),
      "summary": HtmlUnescape().convert(summary),
      "thumbnail": temporaryThumbnail,
      "alt_title": '',
      "author": author,
      "artist": artist,
      "status": status,
      "tags": tags,
      "chapter_count": chapterList.length,
      "chapters": chapterList,
      "source": source,
      "selector": selector,
      "link": id,
      "contains_books": false,
      "is_custom": false,
    };
    debugPrint("Retrieval Complete : /Profile: $title @$source ");
    return Profile.fromMap(x);
  }

  String emoji(String country) {
    country = country.toUpperCase();
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;
    String emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
    return emoji;
  }

  int parseStatus(String string) {
    int status = 0;
    switch (string) {
      case "ongoing":
        {
          status = 1;
        }
        break;
      case "completed":
        {
          status = 2;
        }
        break;
      case "hiatus":
        {
          status = 4;
        }
        break;
      case "abandoned":
        {
          status = 3;
        }
        break;
      default:
        {}
        break;
    }
    return status;
  }

  /// Browse Related
  // Used for latest and all page.
  Future<List<ComicHighlight>> all(int page, Map info,
      {bool latest = false}) async {
    Dio _dio = Dio();
    Response response;
    List<ComicHighlight> highlights = [];
    print(info);

    var contentRating = info['contentRating'];
    var contentLang = info['contentLang'];
    try {
      // Profile Details
      int limit = 30;
      int offset = limit * (page - 1);
      var order = {};
      var params = {
        'limit': limit,
        'offset': offset,
        'contentRating[]': contentRating
      };
      response = await _dio.get(apiURL + '/manga', queryParameters: params);
      print(response.statusCode);
    } catch (err) {
      print(err.response.data);
      debugPrint("MangaDex API Error: GET Highlights");
      throw "Failed to reach MangaDex V5 API.";
    }
    List results = response.data['results'];

    for (Map result in results) {
      result = result['data'];

      var id = result['id'];
      var attributes = result['attributes'];
      var title = HtmlUnescape().convert(attributes['title']['en']);
      ComicHighlight h = ComicHighlight(
          title, id, temporaryThumbnail, selector, source, false, baseURL);
      highlights.add(h);
    }

    return highlights;
  }

  Future<ImageChapter> images(String id, Map info) async {
    Dio _dio = Dio();
    Response response;
    Response mdaHome;
    bool saverMode = info['saver'] == 1;

    try {
      response = await _dio.get(apiURL + '/chapter/$id');
    } catch (err) {
      debugPrint("MangaDex API Error: GET Images");
      throw "Failed to reach MangaDex V5 API.";
    }

    var result = response.data['data']['attributes'];

    var hash = result['hash'];
    var imageRoots = saverMode ? result['dataSaver'] : result['data'];

    try {
      mdaHome = await _dio.get(apiURL + '/at-home/server/$id');
    } catch (err) {
      debugPrint("MangaDex API Error: GET Images");
      throw "Failed to reach MangaDex V5 API.";
    }

    var base = mdaHome.data['baseUrl'];
    List<String> images = [];
    if (imageRoots[0].contains("https://mangaplus.shueisha.co.jp"))
      throw "Licensed Chapter\nUnable to Parse.";
    for (var image in imageRoots) {
      var img = '$base/data/$hash/$image';
      images.add(img);
    }

    ImageChapter out = ImageChapter(
        images: images,
        referer: baseURL,
        source: source,
        count: images.length,
        link: id);
    return out;
  }

  Future<List<ComicHighlight>> tagComics(String id, int page) async {
    Dio _dio = Dio();
    Response response;
    List<ComicHighlight> highlights = [];
    try {
      // Profile Details
      int limit = 30;
      int offset = limit * (page - 1);
      var params = {'limit': limit, 'offset': offset, 'includedTags[]': id};
      response = await _dio.get(apiURL + '/manga', queryParameters: params);
    } catch (err) {
      debugPrint("MangaDex API Error: GET Highlights");
      throw "Failed to reach MangaDex V5 API.";
    }
    List results = response.data['results'];

    for (Map result in results) {
      result = result['data'];

      var id = result['id'];
      var attributes = result['attributes'];
      var title = HtmlUnescape().convert(attributes['title']['en']);
      ComicHighlight h = ComicHighlight(
          title, id, temporaryThumbnail, selector, source, false, baseURL);
      highlights.add(h);
    }
    return highlights;
  }

  Future<List<ComicHighlight>> browse(Map query, Map info) async {
    Dio _dio = Dio();
    Response response;
    List<ComicHighlight> highlights = [];
    Map<String, dynamic> params = {};

    String title = query['title'];
    int page = query['page'] ?? 1;

    // Inc Exc
    List inc = query['include'] ?? [];
    List exc = query['exclude'] ?? [];
    String included = inc.map((e) => "$e").join(",");
    String excluded = exc.map((e) => "-$e").join(",");

    // Sort
    String sort = query['sort'] ?? "";
    String ascDesc = query['order'] ?? 'desc';

    // Status
    List s = query['status'] ?? [];
    String status = s.map((e) => "-$e").join(",");

    // Content Rating
    List contentRating = info['contentRating'] ?? [];

    // Demographic
    String demo = (query['demographic'] ?? []).map((e) => "-$e").join(",");

    if (title.isNotEmpty) params.putIfAbsent('title', () => title);
    if (included.isNotEmpty)
      params.putIfAbsent('includedTags[]', () => included);
    if (excluded.isNotEmpty)
      params.putIfAbsent('excludedTags[]', () => excluded);
    if (contentRating.isNotEmpty)
      params.putIfAbsent('contentRating[]', () => contentRating);
    if (demo.isNotEmpty)
      params.putIfAbsent('publicationDemographic[]', () => demo);
    if (sort.isNotEmpty) params.putIfAbsent('order[$sort]', () => ascDesc);

    try {
      // Profile Details
      int limit = 30;
      int offset = limit * (page - 1);
      var order = {};
      params.putIfAbsent("limit", () => '30');
      params.putIfAbsent("offset", () => offset);

      response = await _dio.get(apiURL + '/manga', queryParameters: params);
    } catch (err) {
      debugPrint("MangaDex API Error: GET Highlights");
      throw "Failed to reach MangaDex V5 API.";
    }

    List results = [];
    if (response.statusCode != 204) {
      results = response.data['results'];
    }

    for (Map result in results) {
      result = result['data'];
      var id = result['id'];
      var attributes = result['attributes'];
      var title = HtmlUnescape().convert(attributes['title']['en']);
      ComicHighlight h = ComicHighlight(
          title, id, temporaryThumbnail, selector, source, false, baseURL);
      highlights.add(h);
    }
    return highlights;
  }

  Future<List<Tag>> tags() async {
    List<Tag> tags = [];
    Dio _dio = Dio();
    Response response;

    try {
      response = await _dio.get(apiURL + '/manga/tag');
    } catch (err) {
      debugPrint("MangaDex API Error: GET TAGS");
      throw "Failed to reach MangaDex V5 API.";
    }

    List results = [];
    results = response.data;

    for (Map result in results) {
      result = result['data'];
      var id = result['id'];
      var attributes = result['attributes'];
      var title = attributes['name']['en'];

      Tag t = Tag(title, id, selector, true);
      tags.add(t);
    }
    return tags;
  }
}
