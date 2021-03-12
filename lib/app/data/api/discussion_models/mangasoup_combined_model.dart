class MSUserCombined {
  String id;
  String username;
  String avatar;
  int level;

  MSUserCombined.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['name'];
    avatar = map['picture'] ??
        "https://styles.redditmedia.com/t5_2t1vzz/styles/communityIcon_w04a8v4cind51.jpg";
    level = map['level'];
  }

  toMap() => {
        "id": id,
        "username": username,
        "avatar": avatar,
        "level": level,
      };
}
