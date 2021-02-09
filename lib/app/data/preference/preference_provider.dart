import 'package:flutter/cupertino.dart';
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
    comicGridCrossAxisCount =
        _p.getInt(PreferenceKeys.COMIC_GRID_CROSS_AXIS_COUNT) ?? 3;
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

  /// Reader Mode
  /// 1 - Manga
  /// 2 - Webtoon
  setReaderMode(int mode) async {
    SharedPreferences p = await _preferences();
    readerMode = mode;
    p.setInt(PreferenceKeys.READER_MODE, mode);
    notifyListeners();
  }

  /// Reader Scroll Direction
  /// 1 - LTR
  /// 2 - RTL
  setReaderScrollDirection(int mode) async {
    SharedPreferences p = await _preferences();
    readerScrollDirection = mode;
    p.setInt(PreferenceKeys.READER_SCROLL_DIRECTION, mode);
    notifyListeners();
  }

  /// Reader Orientation
  /// 1 - Horizontal
  /// 2 - Vertical
  setReaderOrientation(int mode) async {
    SharedPreferences p = await _preferences();
    readerOrientation = mode;
    p.setInt(PreferenceKeys.MANGA_ORIENTATION, mode);
    notifyListeners();
  }

  /// Reader Padding
  /// true - enable padding
  /// false - disable padding
  setReaderPadding(bool padding) async {
    SharedPreferences p = await _preferences();
    readerPadding = padding;
    p.setBool(PreferenceKeys.MANGA_PADDING, padding);
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
}
