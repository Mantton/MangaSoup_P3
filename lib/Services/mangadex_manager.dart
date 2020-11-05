import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DexHub {
  final String baseURL = "https://mangadex.org";
  final String apiURL = "https://mangadex.org/api";
  final String selector = 'mangadex';
  final String source = 'MangaDex';

  final Map tagsDict = {
    1: '4-koma',
    4: 'Award Winning',
    7: 'Doujinshi',
    21: 'Oneshot',
    36: 'Long Strip',
    42: 'Adaptation',
    43: 'Anthology',
    44: 'Web Comic',
    45: 'Full Color',
    46: 'User Created',
    47: 'Official Colored',
    48: 'Fan Colored',
    2: 'Action',
    3: 'Adventure',
    5: 'Comedy',
    8: 'Drama',
    10: 'Fantasy',
    13: 'Historical',
    14: 'Horror',
    17: 'Mecha',
    18: 'Medical',
    20: 'Mystery',
    22: 'Psychological',
    23: 'Romance',
    25: 'Sci-Fi',
    28: 'Shoujo Ai',
    30: 'Shounen Ai',
    31: 'Slice of Life',
    33: 'Sports',
    35: 'Tragedy',
    37: 'Yaoi',
    38: 'Yuri',
    41: 'Isekai',
    51: 'Crime',
    52: 'Magical Girls',
    53: 'Philosophical',
    54: 'Superhero',
    55: 'Thriller',
    56: 'Wuxia',
    6: 'Cooking',
    11: 'Gyaru',
    12: 'Harem',
    16: 'Martial Arts',
    19: 'Music',
    24: 'School Life',
    34: 'Supernatural',
    40: 'Video Games',
    57: 'Aliens',
    58: 'Animals',
    59: 'Crossdressing',
    60: 'Demons',
    61: 'Delinquents',
    62: 'Genderswap',
    63: 'Ghosts',
    64: 'Monster Girls',
    65: 'Loli',
    66: 'Magic',
    67: 'Military',
    68: 'Monsters',
    69: 'Ninja',
    70: 'Office Workers',
    71: 'Police',
    72: 'Post-Apocalyptic',
    73: 'Reincarnation',
    74: 'Reverse Harem',
    75: 'Samurai',
    76: 'Shota',
    77: 'Survival',
    78: 'Time Travel',
    79: 'Vampires',
    80: 'Traditional Games',
    81: 'Virtual Reality',
    82: 'Zombies',
    83: 'Incest',
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

    http.Response response =
        await http.get(url, headers: {'Cookie': stringifyCookies(data)});

    var document = parse(response.body);
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
    print(link);
    var cookies = {};
    if (link.contains("http")) {
      var strings = link.split('/');
      link = strings[4];
    }

    var profileURL = apiURL + '/manga/$link';
    print(profileURL);
    var response = await http
        .get(profileURL, headers: {'Cookie': stringifyCookies(cookies)});

    var document = response.body;
    var c;
    try {
      c = jsonDecode(document);
    } on FormatException catch (e) {
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
      tags.add({"tag": tagsDict[tag] ?? tag, "link": "", "selector": selector});
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
    print(chapters.keys.toList().length);
    var keys = chapters.keys.toList();
    List chapterList = [];
    for (var k in keys) {
      var chapter = chapters[k];
      String volume = chapter['volume'];
      String chapterName = chapter['chapter'];
      String chapterTitle = chapter['title'];
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
      "link": link,
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
}
