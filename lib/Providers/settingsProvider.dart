
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier{
  Map config = Map();

  final Map defaultConfig = {
    "reader_mode": 1,
    "hentai_save": false,
    "history_hide_nsfw": false,
  };

  /// Mini Settings Provider
  init() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String encodedConfig = _prefs.getString("config");
    if (encodedConfig != null)
      config = jsonDecode(encodedConfig);
    else
      config = defaultConfig;
    notifyListeners();
  }

  get({@required String settingName}) async{
    return config['$settingName'];
  }

  save({@required String settingName, @required value}) async{
    config["$settingName"] = value;
  }

}


