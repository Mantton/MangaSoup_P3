class MALTrackResult {
  int id;
  String title;
  String thumbnail;
  String synopsis;
  String status;

  MALTrackResult.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    thumbnail = map['main_picture']['medium'];
    synopsis = map['synopsis'];
    status = map['status'];
  }
}

class MALDetailedTrackResult {
  int id;
  String title;
  String thumbnail;
  String synopsis;
  String status;

  MALDetailedTrackResult.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    thumbnail = map['main_picture']['medium'];
    synopsis = map['synopsis'];
    status = map['status'];
  }
}
