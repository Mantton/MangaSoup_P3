import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';

class BrowseProvider with ChangeNotifier {
  Map data = Map();
  Map encodedData = {};

  init(List maps) {
    // Essentially create data map by loading the defaults of each
    data.clear();
    encodedData.clear();
    for (var map in maps) {
      SourceSetting setting = SourceSetting.fromMap(map);
      if (setting.type == 2) {
        data['${setting.selector}'] = setting.options[0];
      } else if (setting.type == 3) {
        if (setting.name.contains("Genre"))
          data["${setting.selector}"] = [];
        else {
          data['included_tags'] = [];
          data['excluded_tags'] = [];
        }
      } else {
        data["${setting.selector}"] =
            null; // Default TextField value to empty string
      }
    }
    print(data);
    notifyListeners();
  }

  String save(String key, int type, var option) {
    switch (type) {
      case 1:
        data['$key'] = option.toString();
        encodedData["$key"] = option.toString();
        notifyListeners();
        return key;
      case 2:
        print(option.selector);
        data['$key'] = option;
        encodedData['$key'] = option.selector;
        notifyListeners();
        return key;
      case 3:
        data['$key'] = option;
        encodedData['$key'] = option.map((e) => e.selector).toList();
        notifyListeners();
        return key;
      default:
        return key;
    }
  }

  reset(List maps) {
    init(maps);
  }
}
