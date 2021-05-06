class MALUser {
  int id;
  String username;
  String avatar;
  String location;

  MALUser.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['name'];
    avatar = map['picture'] ??
        "https://styles.redditmedia.com/t5_2t1vzz/styles/communityIcon_w04a8v4cind51.jpg";
    location = map['location'] ?? "MangaSoup Home";
  }
}

class AniListUser {
  int id;
  String username;
  String avatar;
  String about;
  var count;
  var meanScore;
  var chaptersRead;
  var volumesRead;

  AniListUser.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['name'];
    avatar = map['avatar']['large'] ??
        "https://styles.redditmedia.com/t5_2t1vzz/styles/communityIcon_w04a8v4cind51.jpg";
    about = map['about'];
    var stats = map['statistics']['manga'];
    count = stats['count'];
    meanScore = stats['meanScore'];
    chaptersRead = stats['chaptersRead'];
    volumesRead = stats['volumesRead'];
  }
}
