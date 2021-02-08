class DexProfile {
  int id;
  String username;
  String avatar;
  String biography;
  String website;

  DexProfile(this.id, this.username, this.avatar);

  DexProfile.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['username'];
    avatar =
        map['avatar'] ?? "https://mangadex.org/images/avatars/default1.jpg";
    biography = map['biography'];
    website = map["website"];
  }

  Map<String, dynamic> toMap() =>
      {"id": id, "username": username, "avatar": avatar, "website": website, "biography":biography};
}
