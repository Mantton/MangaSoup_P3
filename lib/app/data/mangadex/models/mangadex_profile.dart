class DexProfile {
  int id;
  String username;
  String avatar;

  DexProfile(this.id, this.username, this.avatar);

  DexProfile.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['username'];
    avatar =
        map['avatar'] ?? "https://mangadex.org/images/avatars/default1.jpg";
  }

  Map<String, dynamic> toMap() =>
      {"id": id, "username": username, "avatar": avatar};
}
