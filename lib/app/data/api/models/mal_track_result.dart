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
  int chapterCount;
  MyListStatus userStatus;

  MALDetailedTrackResult.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    thumbnail = map['main_picture']['medium'];
    synopsis = map['synopsis'];
    status = map['status'];
    chapterCount = map['num_chapters'];
    userStatus = map['my_list_status'] != null
        ? MyListStatus.fromMap(map['my_list_status'])
        : null;
  }
}

class MyListStatus {
  var status;
  int score;
  int chaptersRead;
  String startDate;
  String endDate;

  MyListStatus.fromMap(Map<String, dynamic> map) {
    status = map['status'];
    score = map['score'];
    chaptersRead = map['num_chapters_read'];
    startDate = map['start_date'];
    endDate = map['end_date'];
  }
}