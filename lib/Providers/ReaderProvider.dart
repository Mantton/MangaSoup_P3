import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';

class ReaderProvider with ChangeNotifier {
  /// Chapter
  Chapter currentChapter;
  Chapter previousChapter;
  Chapter nextChapter;

  /// Images
  List<ImageChapter> loadedChapters = List();
  ImageChapter currentImageChapter;
  ImageChapter previousImageChapter;
  ImageChapter nextImageChapter;

  initChapter(ImageChapter chapter) {
    loadedChapters.clear();
    loadedChapters.add(chapter);
    page = 1;
    notifyListeners();
  }

  addChapter(ImageChapter chapter) {
    loadedChapters.add(chapter);
    notifyListeners();
  }

  /// Reader Mode
  int readerMode = 0;
  Map readerModeOptions = {
    0: "Manga",
    1: "Webtoon",
    2: "Paged Vertical",
  };

  setReaderMode(int mode) {
    readerMode = mode;
    notifyListeners();
  }

  /// Orientation
  int orientationMode = 0;
  Map orientationOptions = {
    0: "Horizontal",
    1: "Vertical",
  };

  setOrientationMode(int mode) {
    orientationMode = mode;
    notifyListeners();
  }

  /// Scroll Direction
  int scrollDirectionMode = 0;
  Map scrollDirectionOptionsHorizontal = {
    0: "Left to Right",
    1: "Right to Left",
  };
  Map scrollDirectionOptionsVertical = {
    0: "Vertical Drag Down",
    1: "Vertical Drag Up",
  };

  setScrollDirectionMode(int mode) {
    scrollDirectionMode = mode;
    notifyListeners();
  }

  /// Snapping
  int snappingMode = 0;
  Map snappingModeOptions = {
    0: true,
    1: false,
  };

  setSnappingMode(int mode) {
    snappingMode = mode;
    notifyListeners();
  }

  /// Padding
  int paddingMode = 0;
  Map paddingModeOptions = {
    0: true,
    1: false,
  };

  setPaddingMode(int mode) {
    paddingMode = mode;
    notifyListeners();
  }

  /// Page
  int page = 1;

  setPage(int p) {
    page = p;
    notifyListeners();
  }
}
