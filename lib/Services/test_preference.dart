import 'dart:convert';

import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestPreference {
  SharedPreferences _preferences;

  init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  setName(String name) {
    init();
    _preferences.setString("test", name);
  }

  getName() {
    init();
    return _preferences.getString("test");
  }

    /// Source
  setSource(Source source) {
    Map encoded = source.toMap();
    _preferences.setString("source", jsonEncode(encoded));
  }

  loadSource() {
    Map y = jsonDecode(_preferences.getString('source'));
    return Source.fromMap(y);
  }
}
