

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider with ChangeNotifier{
  SharedPreferences _prefs;
  // Init at launch

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  setMangadexProfile(){

  }
}