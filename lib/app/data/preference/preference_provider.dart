import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keys.dart';

class PreferenceProvider with ChangeNotifier {
  SharedPreferences _prefs;
  // Init at launch

  Future<void> initPreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> loadValues() async {
    // Initialize Values or Load Defaults
    SharedPreferences _p = await _preferences();

    /// READER
    readerMode = _p.getInt(PreferenceKeys.READER_MODE) ?? 1;
    readerScrollDirection =
        _p.getInt(PreferenceKeys.READER_SCROLL_DIRECTION) ?? 1;
    readerOrientation = _p.getInt(PreferenceKeys.MANGA_ORIENTATION) ?? 1;
    readerPadding = _p.getBool(PreferenceKeys.MANGA_PADDING) ?? true;
    readerPageSnapping = _p.getBool(PreferenceKeys.MANGA_SNAPPING) ?? true;
    comicGridCrossAxisCount =
        _p.getInt(PreferenceKeys.COMIC_GRID_CROSS_AXIS_COUNT) ?? 3;
    scaleToMatchIntended =
        _p.getBool(PreferenceKeys.SCALE_GRID_TO_MATCH_INTENDED) ?? true;
    maxScrollVelocity = _p.getDouble(PreferenceKeys.WEBTOON_MSV) ?? 8500.0;
    showUnreadCount =
        _p.getBool(PreferenceKeys.LIBRARY_SHOW_UNREAD_COUNT) ?? false;
    libraryViewMode = _p.getInt(PreferenceKeys.LIBRARY_VIEW_TYPE) ?? 1;
    notifyListeners();
    return true;
  }

  Future<SharedPreferences> _preferences() async {
    if (_prefs != null)
      return _prefs;
    else {
      await initPreference();
      return _prefs;
    }
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
    SharedPreferences p = await _preferences();
    readerMode = mode;
    p.setInt(PreferenceKeys.READER_MODE, mode);
    notifyListeners();
  }

  /// Reader Scroll Direction
  /// 1 - LTR
  /// 2 - RTL
  Map readerScrollDirectionOptionsHorizontal = {1: "Left to Right", 2: "Right to Left"};
  Map readerScrollDirectionOptionsVertical = {1: "Downward Swipe", 2: "Upward Swipe"};
  setReaderScrollDirection(int mode) async {
    SharedPreferences p = await _preferences();
    readerScrollDirection = mode;
    p.setInt(PreferenceKeys.READER_SCROLL_DIRECTION, mode);
    notifyListeners();
  }

  /// Reader Orientation
  /// 1 - Horizontal
  /// 2 - Vertical
  Map readerOrientationOptions = {1: "Horizontal", 2: "Vertical"};
  setReaderOrientation(int mode) async {
    SharedPreferences p = await _preferences();
    readerOrientation = mode;
    p.setInt(PreferenceKeys.MANGA_ORIENTATION, mode);
    notifyListeners();
  }

  /// Reader Padding
  /// true - enable padding
  /// false - disable padding
  Map readerPaddingOptions = {true: "Enabled", false: "Disabled"};
  setReaderPadding(bool padding) async {
    SharedPreferences p = await _preferences();
    readerPadding = padding;
    p.setBool(PreferenceKeys.MANGA_PADDING, padding);
    notifyListeners();
  }

  /// Reader Snapping
  /// true - enable padding
  /// false - disable padding
  Map readerPageSnappingOptions = {true: "Enabled", false: "Disabled"};
  setReaderPageSnapping(bool padding) async {
    SharedPreferences p = await _preferences();
    readerPageSnapping = padding;
    p.setBool(PreferenceKeys.MANGA_SNAPPING, padding);
    notifyListeners();
  }

  /// GENERAL SETTINGS

  /// Comic Grid Cross Axis Count
  int comicGridCrossAxisCount;

  setCrossAxisCount(int count) async {
    SharedPreferences p = await _preferences();
    comicGridCrossAxisCount = count;
    p.setInt(PreferenceKeys.COMIC_GRID_CROSS_AXIS_COUNT, count);
    notifyListeners();
  }

  /// SCALE TO MATCH INTENDED LOOL
  bool scaleToMatchIntended;

  setSTMI(bool stmi) async {
    SharedPreferences p = await _preferences();
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
    SharedPreferences p = await _preferences();
    maxScrollVelocity = v;
    p.setDouble(PreferenceKeys.WEBTOON_MSV, v);
    notifyListeners();
  }

  /// Library View Type
  int libraryViewMode;

  setLibraryViewMode(int mode) async {
    SharedPreferences p = await _preferences();
    libraryViewMode = mode;
    p.setInt(PreferenceKeys.LIBRARY_VIEW_TYPE, mode);
    notifyListeners();
  }

  /// SHOW UNREAD CHAPTER COUNT
  bool showUnreadCount;

  setSURCM(bool surcm) async {
    // SURCM = Show UnRead Count Mode
    SharedPreferences p = await _preferences();
    scaleToMatchIntended = surcm;
    p.setBool(PreferenceKeys.LIBRARY_SHOW_UNREAD_COUNT, surcm);
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
