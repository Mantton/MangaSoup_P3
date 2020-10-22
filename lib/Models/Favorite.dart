import 'dart:convert';

import 'package:mangasoup_prototype_3/Models/Comic.dart';

class Favorite {
  ComicHighlight highlight;
  int id;
  String collection;
  int chapterCount;
  int updateCount;

  Favorite(this.id, this.highlight, this.collection, this.chapterCount,
      this.updateCount);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "comicHighlight": jsonEncode(highlight.toMap()),
      "collection": collection,
      "chapterCount": chapterCount,
      "updateCount": updateCount,
      "link":highlight.link
    };
  } // Convert to Map

  Favorite.fromMap(Map<String, dynamic> map) {
    highlight = ComicHighlight.fromMap(jsonDecode(map['comicHighlight']));
    id = map['id'];
    collection = map["collection"];
    chapterCount = map["chapterCount"];
    updateCount = map["updateCount"];
  }
}
