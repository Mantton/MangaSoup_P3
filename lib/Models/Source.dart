class Source {
  String name;
  bool isEnabled;
  String server;
  String language;
  String thumbnail;
  bool vipProtected;
  String sourcePack;
  bool isHentai;
  String selector;
  String url;
  List sorters;
  List settings;
  Map userLocalSettings;
  List filters;
  bool loginProtected;
  bool cloudFareProtected;


  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "is_enabled": isEnabled,
      "server": server,
      "language": language,
      "thumbnail": thumbnail,
      "is_vip": vipProtected,
      "source_pack": sourcePack,
      "is_hentai": isHentai,
      "selector": selector,
      "sorters": sorters,
      "settings": settings,
      "filters": filters,
      "login": loginProtected,
      "cloudfare": cloudFareProtected,
    };
  }

  Source.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    isEnabled = map['enabled'];
    server = map['server_selector'];
    language = map['language'];
    thumbnail = map['thumbnail'];
    vipProtected = map['vip_protected'];
    sourcePack = map['source_pack'];
    isHentai = map['is_hentai'];
    selector = map['selector'];
    url = map['base_url'];
    sorters = map['sorters'];
    settings = map['settings'];
    filters = map["filters"];
    cloudFareProtected = map['cloudfare'];
    loginProtected = map['login'];
  }
}
