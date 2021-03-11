class LanguageServer {
  String name;
  String selector;
  bool stable;

  LanguageServer.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    selector = map['selector'];
    stable = map['stable'];
  }
}
