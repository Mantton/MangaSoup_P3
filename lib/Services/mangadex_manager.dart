import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:mangasoup_prototype_3/app/data/mangadex/models/mangadex_profile.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DexHub {
  final String baseURL = "https://mangadex.org";
  final String apiV2URL = "https://api.mangadex.org/v2";
  final String selector = 'mangadex';
  final String source = 'MangaDex';

  final Map tagsDict = {
    "1": '4-Koma',
    "2": 'Action',
    "3": 'Adventure',
    "4": 'Award Winning',
    "5": 'Comedy',
    "6": 'Cooking',
    "7": 'Doujinshi',
    "8": 'Drama',
    "9": 'Ecchi',
    "10": 'Fantasy',
    "11": 'Gyaru',
    "12": 'Harem',
    "13": 'Historical',
    "14": 'Horror',
    "16": 'Martial Arts',
    "17": 'Mecha',
    "18": 'Medical',
    "19": 'Music',
    "20": 'Mystery',
    "21": 'Oneshot',
    "22": 'Psychological',
    "23": 'Romance',
    "24": 'School Life',
    "25": 'Sci-Fi',
    "28": 'Shoujo Ai',
    "30": 'Shounen Ai',
    "31": 'Slice of Life',
    "32": 'Smut',
    "33": 'Sports',
    "34": 'Supernatural',
    "35": 'Tragedy',
    "36": 'Long Strip',
    "37": 'Yaoi',
    "38": 'Yuri',
    "40": 'Video Games',
    "41": 'Isekai',
    "42": 'Adaptation',
    "43": 'Anthology',
    "44": 'Web Comic',
    "45": 'Full Color',
    "46": 'User Created',
    "47": 'Official Colored',
    "48": 'Fan Colored',
    "49": 'Gore',
    "50": 'Sexual Violence',
    "51": 'Crime',
    "52": 'Magical Girls',
    "53": 'Philosophical',
    "54": 'Superhero',
    "55": 'Thriller',
    "56": 'Wuxia',
    "57": 'Aliens',
    "58": 'Animals',
    "59": 'Crossdressing',
    "60": 'Demons',
    "61": 'Delinquents',
    "62": 'Genderswap',
    "63": 'Ghosts',
    "64": 'Monster Girls',
    "65": 'Loli',
    "66": 'Magic',
    "67": 'Military',
    "68": 'Monsters',
    "69": 'Ninja',
    "70": 'Office Workers',
    "71": 'Police',
    "72": 'Post-Apocalyptic',
    "73": 'Reincarnation',
    "74": 'Reverse Harem',
    "75": 'Samurai',
    "76": 'Shota',
    "77": 'Survival',
    "78": 'Time Travel',
    "79": 'Vampires',
    "80": 'Traditional Games',
    "81": 'Virtual Reality',
    "82": 'Zombies',
    "83": 'Incest',
    "84": 'Mafia',
    "85": 'Villainess',
  };

  String regexLink(String link) {
    final regexp = RegExp(r"/title/.*/");
    String match = regexp.firstMatch(link)[0];
    return match.substring(0, match.length - 1);
  }

  Map<String, dynamic> prepareHeaders(Map info) {
    Map cookies = info['cookies'] ?? Map<String, dynamic>();

    Map<String, dynamic> data = Map();
    data.addAll(cookies);
    data['mangadex_h_toggle'] = info['nsfw'];
    String encodedCookies = stringifyCookies(data);
    Map<String, dynamic> browseHeaders = {
      "Cookie": "$encodedCookies",
      "User-Agent": "MangaSoup/0.0.2",
      "Access-Control-Allow-Origin": "*",
      "referer": "https://mangadex.org",
      "origin": "https://mangadex.org"
    };
    return browseHeaders;
  }

  List<ComicHighlight> scrapeMangaDex(var document) {
    List<ComicHighlight> highlights = [];
    var comics = document
        .querySelectorAll('div.manga-entry.col-lg-6.border-bottom.pl-0.my-1');
    if (comics.isNotEmpty) {
      for (var comic in comics) {
        var thumbnail = baseURL +
            comic
                .querySelector('div.rounded.large_logo.mr-2 > a> img')
                .attributes['src'];
        var title =
            comic.querySelector('a.ml-1.manga_title.text-truncate').text;
        var link = baseURL +
            regexLink(comic
                .querySelector('a.ml-1.manga_title.text-truncate')
                .attributes['href']);
        highlights.add(ComicHighlight.fromMap({
          'title': HtmlUnescape().convert(title),
          'link': link,
          'thumbnail': thumbnail,
          'source': source,
          'selector': selector
        }));
      }
    } else {
      comics =
          document.querySelectorAll('div.manga-entry.row.m-0.border-bottom');

      if (comics.isNotEmpty) {
        for (var comic in comics) {
          var thumbnail = baseURL +
              "/images/manga/${comic.attributes['data-id']}.large.jpg";

          var title =
              comic.querySelector('a.ml-1.manga_title.text-truncate').text;
          var link = baseURL +
              regexLink(comic
                  .querySelector('a.ml-1.manga_title.text-truncate')
                  .attributes['href']);
          highlights.add(ComicHighlight.fromMap({
            'title': HtmlUnescape().convert(title),
            'link': link,
            'thumbnail': thumbnail,
            'source': source,
            'selector': selector
          }));
        }
      }
    }
    return highlights;
  }

  String stringifyCookies(Map cookies) =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  Future<List<ComicHighlight>> get(
      String sort, int page, Map additionalInfo) async {
    String url = baseURL + '/titles/9/$page?s=$sort#listing';
    Dio _dio = Dio();
    Map<String, dynamic> browseHeaders = prepareHeaders(additionalInfo);
    Response response = await _dio.get(
      url, //
      options: Options(headers: browseHeaders),
    );

    var document = parse(response.data);
    debugPrint("Retrieval Complete : /all @$source s/$sort, p/$page");
    return scrapeMangaDex(document);
  }

  Future<List<ComicHighlight>> getTagComics(
      String sort, int page, var link, Map additionalInfo) async {
    String url = baseURL +
        '/genre/$link/${tagsDict[link].toString().replaceAll(" ", "-")}/${sort.isNotEmpty ? sort : "9"}/$page';

    Dio _dio = Dio();
    Map<String, dynamic> browseHeaders = prepareHeaders(additionalInfo);
    Response response = await _dio.get(
      url, //
      options: Options(headers: browseHeaders),
    );

    var document = parse(response.data);
    debugPrint("Retrieval Complete : /all @$source s/$sort, p/$page");
    return scrapeMangaDex(document);
  }

  Future<Profile> profile(String link, Map info) async {
    List userLanguages = info['mangadex_languages'] ?? List();
    // debugPrint("Languages: $userLanguages");
    String comicLink = link;
    // print("MD LINK: $comicLink");
    if (link.contains("http")) {
      var strings = link.split('/');
      link = strings.last;
    }
    var profileURL = apiV2URL + '/manga/$link';
    // print("MD API LINK: $profileURL");
    //, headers: {'Cookie': stringifyCookies(cookies)}
    Response response;
    Response chapterResponse;

    try {
      response = await Dio().get(profileURL);
      chapterResponse = await Dio().get(profileURL + "/chapters");
    } catch (err) {
      debugPrint("MangaDex API Error: GET Profile");
      throw "Failed to reach MangaDex API";
    }

    Map manga = Map();
    List chapters = List();
    List chapterGroups = List();
    try {
      manga = response.data['data'];
      chapters = chapterResponse.data['data']['chapters'] ?? List();
      chapterGroups = chapterResponse.data['data']['groups'];
    } catch (err) {
      throw "MangaDex API Schema Changed...";
    }

    // Comic Properties
    String title = manga['title'];
    String thumbnail = manga['mainCover'];
    var altTitles = manga['altTitles'];
    if (altTitles is List) {
      List t = altTitles;
      altTitles = t.map((e) => e).join(", ");
    }
    var artist = manga['artist'];
    var author = manga['author'];

    if (artist is List) {
      artist = artist.map((e) => e).join(", ");
      author = author.map((e) => e).join(", ");
    }
    List genres = manga['tags'];
    List tags = [];
    for (int tag in genres) {
      tags.add({
        "tag": tagsDict["$tag"] ?? tag,
        "link": "$tag",
        "selector": selector
      });
    }
    int statusValue = manga["publication"]['status'];
    String status;
    status = statusValue.toString();
    String summary = manga['description'];
    summary = summary.split('\n')[0];

    /// Chapters
    List chapterList = List();
    for (var chapter in chapters) {
      String volume = chapter['volume'];
      String chapterName = chapter['chapter'];
      String groupName = chapterGroups.firstWhere(
          (element) => element['id'] == chapter['groups'][0])['name'];
      groupName = HtmlUnescape().convert(groupName);
      String lang = chapter['language'];
      var finalTitle =
          "${(volume.isNotEmpty) ? "Vol. $volume" : ""} Ch. $chapterName";
      var date =
          DateTime.fromMillisecondsSinceEpoch(chapter['timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      if (userLanguages.contains(lang) || userLanguages.length == 0) {
        chapterList.add({
          "name": finalTitle,
          "link": "https://mangadex.org/chapter/${chapter['id']}",
          "date": formattedDate,
          "maker": "${_emoji(lang)} - $groupName"
        });
      }
    }

    Map<String, dynamic> x = {
      "title": HtmlUnescape().convert(title),
      "summary": HtmlUnescape().convert(summary),
      "thumbnail": thumbnail,
      "alt_title": altTitles,
      "author": author,
      "artist": artist,
      "status": status,
      "tags": tags,
      "chapter_count": chapterList.length,
      "chapters": chapterList,
      "source": source,
      "selector": selector,
      "link": comicLink,
      "contains_books": false,
      "is_custom": false,
    };
    debugPrint("Retrieval Complete : /Profile: $title @$source ");

    return Profile.fromMap(x);
  }

  String replaceThumbnail(String initial) => initial.replaceAll(".large.", ".");

  String _emoji(String country) {
    country = country.toUpperCase();
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;
    String emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
    return emoji;
  }

  Future<List<ComicHighlight>> browse(Map userQuery, Map additionalInfo) async {
    if (additionalInfo["cookies"] == null) throw MissingMangaDexSession;
    List inc = userQuery['included_tags'] ?? [];
    List exc = userQuery['excluded_tags'] ?? [];
    String included = inc.map((e) => "$e").join(",");
    String excluded = exc.map((e) => "-$e").join(",");
    int sort = userQuery['sort_type'] ?? 9;
    int ascDesc = userQuery['sort_order'] ?? 0;
    sort = sort - ascDesc; // See API docs to understand this better
    Map<String, dynamic> params = {
      "title": userQuery['title'],
      "artist": userQuery['artist'],
      "author": userQuery['author'],
      "tag_mode_exc": "any",
      "tag_mode_inc": "any",
      "tags": included + excluded,
      "s": sort,
    };
    String url = baseURL + '/search';
    Dio _dio = Dio();

    try {
      Response response = await _dio.get(
        url,
        queryParameters: params,
        //
        options: Options(headers: prepareHeaders(additionalInfo)),
      );

      // print(response.request.uri);
      String responseHeaders = response.headers.map.toString();
      // Session
      if (responseHeaders.contains("mangadex_session=deleted")) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs
            .remove("mangadex_cookies")
            .then((value) => showSnackBarMessage("MangaDex Session Revoked"));
        throw "MangaDex Authorization Error";
      }
      var document = parse(response.data);
      return scrapeMangaDex(document);
    } on DioError catch (e) {
      throw "${e.response.statusMessage}";
    }
  }

  Future<List<ComicHighlight>> search(String query, Map additionalInfo) async {
    return await browse({"title": query}, additionalInfo);
  }

  Future<List<Tag>> getTags() async {
    List<Tag> tags = List();

    tagsDict.forEach((key, value) {
      tags.add(
        Tag.fromMap(
          {"tag": "${tagsDict[key]}", "link": "$key", "selector": selector},
        ),
      );
    });
    return tags;
  }

  Future<ComicHighlight> imageSearchViewComic(int id) async {
    Dio _dio = Dio();
    Response response =
        await _dio.get("https://mangadex.org/api/v2/chapter/$id");

    int mangaID = response.data['data']['mangaId'];
    Profile _profile = await profile("https://mangadex.org/title/$mangaID",
        await prepareAdditionalInfo(source));
    ComicHighlight newHighlight = ComicHighlight(_profile.title, _profile.link,
        _profile.thumbnail, selector, source, false, baseURL);
    return newHighlight;
  }

  Future<ImageChapter> images(String chapterLink, Map info) async {
    String link = chapterLink.split("/").last;
    Dio _dio = Dio();
    int saverMode = info['saver'];
    String imageAPI = "https://mangadex.org/api/v2/chapter/";
    // print(imageAPI + link);
    /// https://mangadex.org/api/v2//chapter/1100871?saver=1
    Response response;
    try {
      response = await _dio.get(imageAPI + link,
          queryParameters: {"saver": saverMode},
          options: Options(headers: prepareHeaders(info)));
    } catch (err) {
      if (err is DioError) {
        DioError e = err;
        debugPrint("${e.response.data}");
        throw "Restricted Manga\nContact MangaDex Staff or Discord for more information";
      } else
        throw "Restricted Manga\nContact MangaDex Staff or Discord for more information";
    }

    // Variables
    List<String> images = List();
    List links = response.data['data']['pages'];
    String hash =
        response.data['data']['server'] + response.data['data']['hash'] + "/";

    for (String link in links) {
      String l = hash + link;
      images.add(l);
    }

    ImageChapter result = ImageChapter(
        images: images,
        referer: baseURL,
        source: source,
        count: images.length,
        link: chapterLink);

    return result;
    // queryParameters: params,
    //
    // options: Options(headers: prepareHeaders(additionalInfo)),
  }

  Future<void> logout() async {
    Map info = await prepareAdditionalInfo("mangadex");
    Map headers = prepareHeaders(info);
    headers.putIfAbsent("x-requested-with", () => "XMLHttpRequest");
    await Dio().get(
      baseURL + "/ajax/actions.ajax.php?function=logout",
      options: Options(headers: headers),
    );
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove(PreferenceKeys.MANGADEX_PROFILE);
    _prefs.remove("mangadex_cookies");
  }

  Future<DexProfile> setUserProfile(Map additionalInfo) async {
    try {
      Response response = await Dio().get(
        apiV2URL + "/user/me",
        options: Options(headers: prepareHeaders(additionalInfo)),
      );
      DexProfile userProfile = DexProfile.fromMap(response.data["data"]);
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      await _prefs.setString(
        PreferenceKeys.MANGADEX_PROFILE,
        jsonEncode(
          userProfile.toMap(),
        ),
      );
      return userProfile;
    } on DioError catch (e) {
      if (e.response.statusCode == 403) {
        if (e.response.headers
            .toString()
            .contains("mangadex_session=deleted")) {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs
              .remove("mangadex_cookies")
              .then((value) => showSnackBarMessage("MangaDex Session Revoked"));
        }
        throw "${e.response.statusCode}, Authorization Error";
      } else if (e.response.statusCode == 500) {
        throw "${e.response.statusCode}, MangaDex Servers are currently down";
      } else if (e.response.statusCode == 502) {
        throw "${e.response.statusCode}, MangaDex is under heavy load, try again.";
      } else
        throw e.response.statusMessage;
    }
  }

  Future<List<ComicHighlight>> getUserLibrary(Map additionalInfo) async {
    var headers = prepareHeaders(additionalInfo);
    try {
      Response response = await Dio().get(apiV2URL + "/user/me/followed-manga",
          options: Options(headers: headers), queryParameters: {"hentai": "1"});

      List data = response.data['data'];
      List<ComicHighlight> comics = List();
      for (Map d in data) {
        comics.add(ComicHighlight.fromMangaDex(d));
      }
      return comics;
    } on DioError catch (e) {
      if (e.response.statusCode == 403) {
        if (e.response.headers
            .toString()
            .contains("mangadex_session=deleted")) {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs
              .remove("mangadex_cookies")
              .then((value) => showSnackBarMessage("MangaDex Session Revoked"));
        }
        throw "${e.response.statusCode}, Authorization Error";
      } else if (e.response.statusCode == 500) {
        throw "${e.response.statusCode}, MangaDex Servers are currently down";
      } else if (e.response.statusCode == 502) {
        throw "${e.response.statusCode}, MangaDex is under heavy load, try again.";
      } else
        throw e.response.statusMessage;
    }
  }

  Future<void> markChapter(List<int> ids, bool read, Map additionalInfo) async {
    var headers = prepareHeaders(additionalInfo);
    await Dio().post(apiV2URL + "/user/me/marker",
        options: Options(headers: headers, contentType: "application/json"),
        data: {"chapters": ids, "read": read});
  }
}
