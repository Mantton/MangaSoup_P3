import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DexHub {
  final String baseURL = "https://mangadex.org";
  final String apiURL = "https://mangadex.org/api";
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

  String stringifyCookies(Map cookies) =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  Future<List<ComicHighlight>> get(
      String sort, int page, Map additionalInfo) async {
    Map cookies = additionalInfo['cookies'] ?? {};
    Map data = Map();
    data.addAll(cookies);
    data['mangadex_h_toggle'] = additionalInfo['nsfw'];
    print(data);

    String url = baseURL + '/titles/9/$page/?s=$sort#listing';
    Dio _dio = Dio();
    String encodedCookies = stringifyCookies(data);
    print(encodedCookies);
    Map<String, dynamic> browseHeaders = {
      "Cookie": encodedCookies,
      "authority": "mangadex.org",
      'user-agent': 'MangaSoup-DexHub-Client/1.0.0',
      'accept-language': 'en-US,en;q=0.9,tr-TR;q=0.8,tr;q=0.7',
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "pragma": "no-cache",
      'referer': 'https://mangadex.org/',
      "Access-Control-Allow-Origin": "*",
      "referer": "https://mangadex.org/search?title=",
      "sec-fetch-dest": "document",
      "sec-fetch-mode": "navigate",
      "sec-fetch-site": "same-origin",
      "upgrade-insecure-requests": 1,
    };
    Response response = await _dio.get(
      url, //
      options: Options(headers: browseHeaders),
    );

    var document = parse(response.data);
    var comics = document
        .querySelectorAll('div.manga-entry.col-lg-6.border-bottom.pl-0.my-1');

    List<ComicHighlight> highlights = [];
    for (var comic in comics) {
      var thumbnail = baseURL +
          comic
              .querySelector('div.rounded.large_logo.mr-2 > a> img')
              .attributes['src'];
      var title = comic.querySelector('a.ml-1.manga_title.text-truncate').text;
      var link = baseURL + comic
          .querySelector('a.ml-1.manga_title.text-truncate')
          .attributes['href'];
      highlights.add(ComicHighlight.fromMap({
        'title': title,
        'link': link,
        'thumbnail': thumbnail,
        'source': source,
        'selector': selector
      }));
    }
    debugPrint("Retrieval Complete : /all @$source s/$sort, p/$page");
    return highlights;
  }

  Future<List<ComicHighlight>> getTagComics(
      String sort, int page, var link, Map additionalInfo) async {
    Map cookies = additionalInfo['cookies'] ?? {};
    Map data = Map();
    data.addAll(cookies);
    data['mangadex_h_toggle'] = additionalInfo['nsfw'];
    print(data);

    String url = baseURL +
        '/genre/$link/${tagsDict[link].toString().replaceAll(" ", "-")}/$sort/$page';

    print(url);
    Dio _dio = Dio();
    String encodedCookies = stringifyCookies(data);
    print(encodedCookies);
    Map<String, dynamic> browseHeaders = {
      "Cookie": encodedCookies,
      "authority": "mangadex.org",
      'user-agent': 'MangaSoup-DexHub-Client/1.0.0',
      'accept-language': 'en-US,en;q=0.9,tr-TR;q=0.8,tr;q=0.7',
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "pragma": "no-cache",
      'referer': 'https://mangadex.org/',
      "Access-Control-Allow-Origin": "*",
      "referer": "https://mangadex.org/search?title=",
      "sec-fetch-dest": "document",
      "sec-fetch-mode": "navigate",
      "sec-fetch-site": "same-origin",
      "upgrade-insecure-requests": 1,
    };
    Response response = await _dio.get(
      url, //
      options: Options(headers: browseHeaders),
    );

    var document = parse(response.data);
    var comics = document
        .querySelectorAll('div.manga-entry.col-lg-6.border-bottom.pl-0.my-1');

    List<ComicHighlight> highlights = [];
    for (var comic in comics) {
      var thumbnail = baseURL +
          comic
              .querySelector('div.rounded.large_logo.mr-2 > a> img')
              .attributes['src'];
      var title = comic.querySelector('a.ml-1.manga_title.text-truncate').text;
      var link = comic
          .querySelector('a.ml-1.manga_title.text-truncate')
          .attributes['href'];
      highlights.add(ComicHighlight.fromMap({
        'title': title,
        'link': baseURL + link,
        'thumbnail': thumbnail,
        'source': source,
        'selector': selector
      }));
    }
    debugPrint("Retrieval Complete : /all @$source s/$sort, p/$page");
    return highlights;
  }

  Future<ComicProfile> profile(String link) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String encodedSettings = _prefs.getString("mangadex_settings");
    Map settings = Map();
    if (encodedSettings != null) {
      settings = jsonDecode(encodedSettings);
    } else
      settings = {};

    List userLanguages = settings['mangadex_languages'] ?? [];

    String comicLink = link;
    if (link.contains("http")) {
      var strings = link.split('/');
      link = strings[4];
    }

    var profileURL = apiURL + '/manga/$link';
    print("API LINK: $profileURL");
    //, headers: {'Cookie': stringifyCookies(cookies)}
    var response = await http.get(profileURL);

    var document = response.body;
    var c;
    try {
      c = jsonDecode(document);
    } on FormatException catch (e) {
      print("$e");

      throw 'MangaDex failed to respond with the appropriate data';
    }

    var manga = c['manga'];
    Map chapters = c['chapter'];

    // Comic Properties
    String title = manga['title'];

    String thumbnail = baseURL + manga['cover_url'];
    var altTitles = manga['alt_names'];
    String artist = manga['artist'];
    String author = manga['author'];
    List genres = manga['genres'];
    List tags = [];
    for (int tag in genres) {
      tags.add(
          {"tag": tagsDict["$tag"] ?? tag, "link": "$tag", "selector": selector});
    }
    int statusValue = manga['status'];
    String status;

    if (statusValue == 1)
      status = "Ongoing";
    else if (statusValue == 2)
      status = "Completed";
    else if (statusValue == 3)
      status = "Cancelled";
    else if (statusValue == 4) status = "Unknown";

    String summary = manga['description'];
    summary = summary.split('\n')[0];
    var keys = chapters.keys.toList();
    List chapterList = [];
    for (var k in keys) {
      var chapter = chapters[k];
      String volume = chapter['volume'];
      String chapterName = chapter['chapter'];
      // String chapterTitle = chapter['title'];
      String groupName = chapter['group_name'];
      String lang = chapter['lang_code'];
      var finalTitle =
          "${(volume.isNotEmpty) ? "Vol. $volume" : ""} Ch. $chapterName";
      var date =
          DateTime.fromMillisecondsSinceEpoch(chapter['timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      if (userLanguages.contains(lang) || userLanguages.length == 0) {
        chapterList.add({
          "name": finalTitle,
          "link": "https://mangadex.org/chapter/$k",
          "date": formattedDate,
          "maker": "${_emoji(lang)} - $groupName"
        });
      }
    }

    Map<String, dynamic> x = {
      "title": title,
      "summary": summary,
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
    };
    return ComicProfile.fromMap(x);
  }

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
    Map cookies = additionalInfo['cookies'];

    if (cookies == null) {
      throw MissingMangaDexSession;
    }
    Map<String, dynamic> data = Map();
    data.addAll(cookies);
    data['mangadex_h_toggle'] = additionalInfo['nsfw'];
    print(data);
    //https://mangadex.org/search?artist=a&author=e&lang_id=1&tag_mode_exc=any&tag_mode_inc=any&tags=-1,-77,9&title=doctor
    Map<String, dynamic> params = {
      "title": userQuery['title'],
      "artist": userQuery['artist'],
      "author": userQuery['author'],
      "lang_id": userQuery['langs'],
      "tag_mode_exc": "any",
      "tag_mode_inc": "any",
      // todo, excluded tags have a - in front
    };

    String url = baseURL + '/search';
    Dio _dio = Dio();
    String encodedCookies = stringifyCookies(data);
    print(encodedCookies);
    Map<String, dynamic> browseHeaders = {
      "Cookie": encodedCookies,
      "authority": "mangadex.org",
      'user-agent': 'MangaSoup-DexHub-Client/1.0.0',
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "pragma": "no-cache",
      'referer': 'https://mangadex.org/',
      "Access-Control-Allow-Origin": "*",
      "referer": "https://mangadex.org/search?title=",
      "sec-fetch-dest": "document",
      "sec-fetch-mode": "navigate",
      "sec-fetch-site": "same-origin",
      "upgrade-insecure-requests": 1,
    };
    Response response = await _dio.get(
      url,
      queryParameters: params,
      //
      options: Options(headers: browseHeaders),
    );
    print(response.headers);
    var document = parse(response.data);
    var comics = document
        .querySelectorAll('div.manga-entry.col-lg-6.border-bottom.pl-0.my-1');

    List<ComicHighlight> highlights = [];
    for (var comic in comics) {
      var thumbnail = baseURL +
          comic
              .querySelector('div.rounded.large_logo.mr-2 > a> img')
              .attributes['src'];
      var title = comic.querySelector('a.ml-1.manga_title.text-truncate').text;
      var link = comic
          .querySelector('a.ml-1.manga_title.text-truncate')
          .attributes['href'];
      highlights.add(ComicHighlight.fromMap({
        'title': title,
        'link': baseURL + link,
        'thumbnail': thumbnail,
        'source': source,
        'selector': selector
      }));
    }

    debugPrint("Retrieval Complete : /all @$source");
    return highlights;
  }

  Future<List<ComicHighlight>> search(String query, Map additionalInfo) async {
    return await browse({"title": query}, additionalInfo);
  }

  Future<bool> login(String username, String password) async {
    Map<String, String> loginHeaders = {
      "method": "POST",
      "path": "/ajax/actions.ajax.php?function=login",
      "origin": "https://mangadex.org",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "same-origin",
      "x-requested-with": "XMLHttpRequest",
      "authority": "mangadex.org",
      'user-agent': 'MangaSoup-DexHub-Client/1.0.0',
      'accept-language': 'en-US,en;q=0.9,tr-TR;q=0.8,tr;q=0.7',
      "pragma": "no-cache",
      'referer': 'https://mangadex.org/',
      "Access-Control-Allow-Origin": "*",
      "Cookie": "",
    };
    Map<String, dynamic> requestBody = {
      "login_username": username,
      "login_password": password,
      "remember_me": 1
    };
    Dio _dio = Dio();
    String url = baseURL + "/ajax/actions.ajax.php?function=login";
    Response response = await _dio.post(url,
        data: (requestBody),
        options: Options(
            headers: loginHeaders,
            contentType: Headers.formUrlEncodedContentType));

    var x = response.headers['set-cookie'];
    print(x.length);
    String session;
    String rememberMeToken;

    try {
      session =
          x.singleWhere((element) => element.contains("mangadex_session"));
      rememberMeToken = x.singleWhere(
          (element) => element.contains("mangadex_rememberme_token"));

      // Splits
      session = session.split("mangadex_session=")[1].split(";")[0];
      rememberMeToken =
          rememberMeToken.split("mangadex_rememberme_token=")[1].split(";")[0];
    } catch (Exception) {
      print("no found element");
      return false;
    }
    print(session);

    if (session == null || rememberMeToken == null) return false;
    print(session);
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setString(
        "mangadex_cookies",
        jsonEncode({
          "mangadex_session": session,
          "mangadex_rememberme_token": rememberMeToken
        }));

    return true;
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
}
