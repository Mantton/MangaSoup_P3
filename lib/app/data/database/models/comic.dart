import 'package:mangasoup_prototype_3/Models/Comic.dart';

class Comic {
  int id;

  // Highlight Information
  String title;
  String link;
  String v2Id;
  String thumbnail;
  String referer;
  bool isNsfw; // Either Hentai or contains adult tags

  // App Information
  String source;
  String sourceSelector;

  // Library Information
  bool inLibrary;
  int chapterCount; // Number of Chapters the manga contains
  int updateCount; // Number of updates available after update check
  int unreadCount; // Number of Unread Chapters
  int viewerMode; // Specifies the mode in which the user views this comic

  // Library Information 2
  DateTime dateAdded;
  int rating;

  // Initialize new Comic
  Comic(
      {this.title,
      this.link,
      this.thumbnail,
      this.referer,
      this.source,
      this.sourceSelector,
      this.chapterCount}) {
    this.id = null;
    this.inLibrary = false;
    this.updateCount = 0;
    this.unreadCount = 0;
    this.viewerMode = 0;
    this.isNsfw = false;
    this.rating = 0;
    this.dateAdded = null;
    this.v2Id = null;
  }

  // Create Comic from map
  Comic.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    link = map['link'];
    thumbnail = map['thumbnail'];
    source = map['source'];
    sourceSelector = map['selector'];
    chapterCount = map['chapter_count'];
    updateCount = map['update_count'];
    unreadCount = map['unread_count'];
    inLibrary = map["in_library"] == 1 ? true : false;
    viewerMode = map['view_mode'];
    isNsfw = map['nsfw'] == 1 ? true : false;
    rating = map['rating'];
    dateAdded = DateTime.fromMicrosecondsSinceEpoch(map['date_added']);
    v2Id = map['v2Id'];
  }

  ComicHighlight toHighlight() {
    return ComicHighlight(
        title, link, thumbnail, sourceSelector, source, isNsfw, "",
        updateCount: updateCount, unreadCount: unreadCount);
  }

  // Create DB Injectable Map from Comic

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "link": link,
      "thumbnail": thumbnail,
      "source": source,
      "selector": sourceSelector,
      "chapter_count": chapterCount,
      "update_count": updateCount,
      "unread_count": unreadCount,
      "in_library": inLibrary ? 1 : 0,
      "view_mode": viewerMode,
      "nsfw": isNsfw ? 1 : 0,
      "rating": rating,
      "date_added": dateAdded.microsecondsSinceEpoch,
      "v2Id": v2Id,
    };
  }
}
