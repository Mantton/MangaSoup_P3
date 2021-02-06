import 'dart:convert';

import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SourcePreference {
  SharedPreferences _preferences;

  init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Source
  setSource(Source source) {
    Map encoded = source.toMap();
    _preferences.setString("source", jsonEncode(encoded));
  }

  loadSource() {
    var x = _preferences.getString('source');
    if (x == null) {
      return null;
    }
    Map y = jsonDecode(x);
    return Source.fromMap(y);
  }
}
