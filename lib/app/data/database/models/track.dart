import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';

class Tracker {
  int id;
  int comicId;
  int trackerType;
  MALTrackStatus status;
  int syncId;
  int mediaId;
  String title;
  int lastChapterRead;
  int totalChapters;
  int score;
  DateTime dateStarted;
  DateTime dateEnded;
  String trackingUrl;

  Tracker({this.comicId, this.trackerType});

  Tracker.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    trackerType = map['tracker_type'];
    comicId = map['comic_id'];
    syncId = map['sync_id'];
    mediaId = map['media_id'];
    title = map['comic_title'];
    lastChapterRead = map['last_read'];
    totalChapters = map['total_chapters'];
    score = map['comic_score'];
    status = getMALStatus(map["status"]);
    dateStarted = map['date_started'] != null
        ? DateTime.fromMicrosecondsSinceEpoch(map['date_started'])
        : null;
    dateEnded = map['date_ended'] != null
        ? DateTime.fromMicrosecondsSinceEpoch(map['date_ended'])
        : null;
  }

  toMap() =>
      {
        "id": id,
        "tracker_type": trackerType,
        "comic_id": comicId,
        "sync_id": syncId,
        "media_id": mediaId,
        "comic_title": title,
        "last_read": lastChapterRead,
        "total_chapters": totalChapters,
        "score": score,
        "date_started":
            dateStarted != null ? dateStarted.microsecondsSinceEpoch : null,
        "date_ended":
            dateEnded != null ? dateEnded.microsecondsSinceEpoch : null,
        "status": getMALStatusString(status),
      };
}
