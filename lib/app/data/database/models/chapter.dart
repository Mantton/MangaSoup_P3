import 'dart:convert';

import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';

class ChapterData {
  // Database
  int id;
  int mangaId;

  // Fields
  String title;
  String link;
  String source;
  String selector;
  List images;

  // Required for some in-app logic
  double generatedChapterNumber;
  int lastPageRead;
  bool read;
  bool bookmarked;
  DateTime timeAccessed;

  ChapterData(
      {this.mangaId,
      this.title,
      this.link,
      this.source,
      this.selector,
      this.generatedChapterNumber}) {
    images = List();
    read = false;
    timeAccessed = DateTime.now();
    bookmarked = false;
    lastPageRead = 1;
  }

  ChapterData.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    mangaId = map['manga_id'];
    title = map['title'];
    link = map['link'];
    source = map['source'];
    selector = map['selector'];
    generatedChapterNumber = double.parse(map['generated_chapter_number']);
    lastPageRead = map['last_page_read'];
    read = map['read'] == 1 ? true : false;
    bookmarked = map['bookmark'] == 1 ? true : false;
    timeAccessed = DateTime.fromMicrosecondsSinceEpoch(map['time_accessed']);
    images = jsonDecode(map['images']);
  }

  Chapter toChapter() {
    return Chapter(title, link, null, null);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "manga_id": mangaId,
      "title": title,
      "link": link,
      "source": source,
      "selector": selector,
      "last_page_read": lastPageRead,
      "generated_chapter_number": generatedChapterNumber.toString(),
      "read": read ? 1 : 0,
      "bookmarked": bookmarked ? 1 : 0,
      "time_accessed": timeAccessed.microsecondsSinceEpoch,
      "images": jsonEncode(images),
    };
  }
}
