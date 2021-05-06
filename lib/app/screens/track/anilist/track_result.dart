class AniListResult {
  int id;
  String title;
  String thumbnail;
  String description;
  String status;

  AniListResult.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title']['romaji'];
    thumbnail = map['coverImage']['large'];
    description = map['description'];
    status = map['status'];
  }
}

class AnilistDetailedResponse {
  int syncId;
  int mangaId;
  String status;
  String title;
  String thumbnail;

  AniListUserStatus userStatus;

  AnilistDetailedResponse.fromMap(Map<String, dynamic> map) {
    syncId = map['id'];
    title = map['media']['title']['romaji'];
    mangaId = map['media']['id'];
    thumbnail = map['media']['coverImage']['large'];
    status = map['status'];
    userStatus = AniListUserStatus.fromMap(map);
  }
}

class AniListUserStatus {
  String status;
  int score;
  int progress;

  AniListUserStatus.fromMap(Map<String, dynamic> map) {
    status = map['status'];
    score = map['scoreRaw'] ~/ 10;
    progress = map['progress'];
  }
}
