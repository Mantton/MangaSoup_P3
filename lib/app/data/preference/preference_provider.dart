import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/mangasoup_combined_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class PreferenceProvider with ChangeNotifier {
  SharedPreferences _prefs;

  // Init at launch

  Future<void> initPreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> loadValues(BuildContext context) async {
    // Initialize Values or Load Defaults
    SharedPreferences _p = await preferences();

    /// READER
    readerMode = _p.getInt(PreferenceKeys.READER_MODE) ?? 1;
    readerScrollDirection =
        _p.getInt(PreferenceKeys.READER_SCROLL_DIRECTION) ?? 1;
    readerOrientation = _p.getInt(PreferenceKeys.MANGA_ORIENTATION) ?? 1;
    comicGridMode = _p.getInt(PreferenceKeys.COMIC_GRID_MODE) ?? 0;
    readerPadding = _p.getBool(PreferenceKeys.MANGA_PADDING) ?? true;
    readerPageSnapping = _p.getBool(PreferenceKeys.MANGA_SNAPPING) ?? true;
    comicGridCrossAxisCount =
        _p.getInt(PreferenceKeys.COMIC_GRID_CROSS_AXIS_COUNT) ?? 3;
    scaleToMatchIntended =
        _p.getBool(PreferenceKeys.SCALE_GRID_TO_MATCH_INTENDED) ?? true;
    maxScrollVelocity = _p.getDouble(PreferenceKeys.WEBTOON_MSV) ?? 8500.0;
    showUnreadCount =
        _p.getBool(PreferenceKeys.LIBRARY_SHOW_UNREAD_COUNT) ?? true;
    libraryViewMode = _p.getInt(PreferenceKeys.LIBRARY_VIEW_TYPE) ?? 1;
    readerBGColor = _p.getInt(PreferenceKeys.READER_BG_COLOR) ?? 0;
    malAutoSync = _p.getBool(PreferenceKeys.MAL_AUTO_SYNC) ?? true;
    readerMaxWidth = _p.getBool(PreferenceKeys.READER_MAX_WIDTH) ?? false;
    readerDoublePagedMode =
        _p.getBool(PreferenceKeys.READER_DOUBLE_MODE) ?? false;
    languageServer = _p.getString(PreferenceKeys.MS_LANG_SERVER) ?? "en";
    updateOnStartUp = _p.getBool(PreferenceKeys.UPDATE_ON_STARTUP) ?? true;
    showTimeInReader = _p.getBool(PreferenceKeys.READER_SHOW_TIME) ?? false;

    msUser = _p.getString(PreferenceKeys.MS_T_USER) != null
        ? MSUserCombined.fromMap(
            jsonDecode(_p.getString(PreferenceKeys.MS_T_USER)))
        : null;

    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    paths = directory.path;
    notifyListeners();
    return true;
  }

  Future<SharedPreferences> preferences() async {
    if (_prefs != null)
      return _prefs;
    else {
      await initPreference();
      return _prefs;
    }
  }

  /// LANGUAGE SERVER

  String languageServer;

  setLanguageServer(String server) async {
    SharedPreferences p = await preferences();
    languageServer = server;
    p.setString(PreferenceKeys.MS_LANG_SERVER, server);
    notifyListeners();
  }

  /// READER SETTINGS
  int readerMode;
  int readerScrollDirection;
  int readerOrientation;
  bool readerPadding;
  bool readerPageSnapping;

  /// Reader Mode
  /// 1 - Manga
  /// 2 - Webtoon
  Map readerModeOptions = {1: "Paged / Manga", 2: "WebToon"};

  setReaderMode(int mode) async {
    SharedPreferences p = await preferences();
    readerMode = mode;
    p.setInt(PreferenceKeys.READER_MODE, mode);
    notifyListeners();
  }

  /// Reader Scroll Direction
  /// 1 - LTR
  /// 2 - RTL
  Map readerScrollDirectionOptionsHorizontal = {
    1: "Left to Right",
    2: "Right to Left"
  };
  Map readerScrollDirectionOptionsVertical = {
    1: "Downward Swipe",
    2: "Upward Swipe"
  };

  setReaderScrollDirection(int mode) async {
    SharedPreferences p = await preferences();
    readerScrollDirection = mode;
    p.setInt(PreferenceKeys.READER_SCROLL_DIRECTION, mode);
    notifyListeners();
  }

  /// Reader Orientation
  /// 1 - Horizontal
  /// 2 - Vertical
  Map readerOrientationOptions = {1: "Horizontal", 2: "Vertical"};

  setReaderOrientation(int mode) async {
    SharedPreferences p = await preferences();
    readerOrientation = mode;
    p.setInt(PreferenceKeys.MANGA_ORIENTATION, mode);
    notifyListeners();
  }

  /// Reader Padding
  /// true - enable padding
  /// false - disable padding
  Map readerPaddingOptions = {true: "Enabled", false: "Disabled"};

  setReaderPadding(bool padding) async {
    SharedPreferences p = await preferences();
    readerPadding = padding;
    p.setBool(PreferenceKeys.MANGA_PADDING, padding);
    notifyListeners();
  }

  Map readerBGColorOptions = {
    0: "Black",
    1: "White",
    2: "Grey",
    3: "Dark Grey",
    4: "Purple"
  };
  int readerBGColor;

  setReaderBGColor(int option) async {
    SharedPreferences p = await preferences();
    readerBGColor = option;
    p.setInt(PreferenceKeys.READER_BG_COLOR, option);
    notifyListeners();
  }

  /// Reader Snapping
  /// true - enable padding
  /// false - disable padding
  Map readerPageSnappingOptions = {true: "Enabled", false: "Disabled"};

  setReaderPageSnapping(bool padding) async {
    SharedPreferences p = await preferences();
    readerPageSnapping = padding;
    p.setBool(PreferenceKeys.MANGA_SNAPPING, padding);
    notifyListeners();
  }

  /// REAder MAx WIdth
  bool readerMaxWidth;

  setReaderMaxWidth(bool max) async {
    SharedPreferences p = await preferences();
    readerMaxWidth = max;
    p.setBool(PreferenceKeys.READER_MAX_WIDTH, max);
    notifyListeners();
  }

  /// GENERAL SETTINGS

  /// Comic Grid Cross Axis Count
  int comicGridCrossAxisCount;

  setCrossAxisCount(int count) async {
    SharedPreferences p = await preferences();
    comicGridCrossAxisCount = count;
    p.setInt(PreferenceKeys.COMIC_GRID_CROSS_AXIS_COUNT, count);
    notifyListeners();
  }

  /// SCALE TO MATCH INTENDED LOOL
  bool scaleToMatchIntended;

  setSTMI(bool stmi) async {
    SharedPreferences p = await preferences();
    scaleToMatchIntended = stmi;
    p.setBool(PreferenceKeys.SCALE_GRID_TO_MATCH_INTENDED, stmi);
    notifyListeners();
  }

  /// WEBTOON READER SCROLL VELOCITY
  Map webtoonMaxScrollVelocityOption = {
    2500.0: "2500",
    4500.0: "4500",
    6500.0: "6500",
    8500.0: "8500",
  };
  double maxScrollVelocity;

  setMSV(double v) async {
    SharedPreferences p = await preferences();
    maxScrollVelocity = v;
    p.setDouble(PreferenceKeys.WEBTOON_MSV, v);
    notifyListeners();
  }

  /// Library View Type
  int libraryViewMode;

  setLibraryViewMode(int mode) async {
    SharedPreferences p = await preferences();
    libraryViewMode = mode;
    p.setInt(PreferenceKeys.LIBRARY_VIEW_TYPE, mode);
    notifyListeners();
  }

  /// SHOW UNREAD CHAPTER COUNT
  bool showUnreadCount;

  setSURCM(bool surcm) async {
    // SURCM = Show UnRead Count Mode
    SharedPreferences p = await preferences();
    showUnreadCount = surcm;
    p.setBool(PreferenceKeys.LIBRARY_SHOW_UNREAD_COUNT, surcm);
    notifyListeners();
  }

  bool malAutoSync;

  setMALAutoSync(bool sync) async {
    // SURCM = Show UnRead Count Mode
    SharedPreferences p = await preferences();
    malAutoSync = sync;
    p.setBool(PreferenceKeys.MAL_AUTO_SYNC, sync);
    notifyListeners();
  }

  bool readerDoublePagedMode;

  setDoublePagedMode(bool mode) async {
    SharedPreferences p = await preferences();
    readerDoublePagedMode = mode;
    p.setBool(PreferenceKeys.MAL_AUTO_SYNC, mode);
    notifyListeners();
  }

  Map comicGridModeOptions = {
    0: "Separated",
    1: "Compact",
  };
  int comicGridMode;

  setComicGridMode(int option) async {
    SharedPreferences p = await preferences();
    comicGridMode = option;
    p.setInt(PreferenceKeys.COMIC_GRID_MODE, option);
    notifyListeners();
  }

  bool updateOnStartUp;

  setUpdateOnStartUp(bool mode) async {
    SharedPreferences p = await preferences();
    updateOnStartUp = mode;
    p.setBool(PreferenceKeys.UPDATE_ON_STARTUP, mode);
    notifyListeners();
  }

  MSUserCombined msUser;

  setMSUsr(MSUserCombined newUsr) async {
    SharedPreferences p = await preferences();
    p.setString(PreferenceKeys.MS_T_USER, jsonEncode(newUsr.toMap()));
    msUser = newUsr;
    notifyListeners();
  }

  removeMSUser() async {
    SharedPreferences p = await preferences();
    p.remove(PreferenceKeys.MS_T_USER);
    msUser = null;
    notifyListeners();
  }

  String paths;

  bool showTimeInReader;

  setShowTimeInReader(bool show) async {
    SharedPreferences p = await preferences();
    showTimeInReader = show;
    p.setBool(PreferenceKeys.READER_SHOW_TIME, show);
    notifyListeners();
  }

  /// Functions
  List<DropdownMenuItem> buildItems(Map pref) => pref.entries
      .map(
        (e) => DropdownMenuItem(
          child: Text(e.value),
          value: e.key,
        ),
      )
      .toList();
}
