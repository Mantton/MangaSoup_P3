class Tracker {
  int id;
  int comicId;
  int trackerType;
  int syncId;
  int mediaId;
  String title;
  double lastChapterRead;
  int totalChapters;
  int score;
  DateTime dateStarted;
  DateTime dateEnded;
  String trackingUrl;

  Tracker.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    trackerType = map['tracker_type'];
    comicId = map['comic_id'];
    syncId = map['sync_id'];
    mediaId = map['media_id'];
    title = map['comic_title'];
    lastChapterRead = double.parse(map['last_read']);
    totalChapters = map['total_chapters'];
    score = map['comic_score'];
    dateStarted = DateTime.fromMicrosecondsSinceEpoch(map['date_started']);
    dateEnded = DateTime.fromMicrosecondsSinceEpoch(map['date_ended']);
  }

  toMap() => {
        "id": id,
        "tracker_type": trackerType,
        "comic_id": comicId,
        "sync_id": syncId,
        "media_id": mediaId,
        "comic_title": title,
        "last_read": lastChapterRead.toString(),
        "total_chapters": totalChapters,
        "score": score,
        "date_started": dateStarted.microsecondsSinceEpoch,
        "date_ended": dateEnded.microsecondsSinceEpoch,
      };
}
