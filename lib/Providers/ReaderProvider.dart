import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class ReaderProvider with ChangeNotifier {
  ApiManager _apiManager = ApiManager();

  ///
  bool downloaded;
  bool loadingMore = false;
  String source;
  int chapterLength;

  bool lastChapter;
  bool firstChapter;
  bool onlyChapter;

  /// Chapter
  Chapter currentChapter;
  Chapter previousChapter;
  Chapter nextChapter;
  Chapter lastLoaded;
  List<Chapter> chapterList;
  int chapterIndex;

  /// Images
  List<ImageChapter> loadedChapters = List();
  ImageChapter currentImageChapter;
  ImageChapter previousImageChapter;
  ImageChapter nextImageChapter;

  init({
    @required ImageChapter imageChapter,
    @required Chapter selectedChapter,
    @required bool isDownloaded,
    @required List<Chapter> chapterListObject,
    @required String chapterSource,
  }) {
    clear();
    loadedChapters.add(imageChapter);

    // Testing new
    currentChapter = selectedChapter;
    downloaded = isDownloaded;
    currentImageChapter = imageChapter;
    print(imageChapter.link);
    chapterList = chapterListObject;
    page = 1;
    source = chapterSource;
    lastLoaded = currentChapter;
    chapterLength = currentImageChapter.count;

    if (chapterList.isNotEmpty) {
      chapterIndex = chapterList
          .indexWhere((element) => element.link == currentChapter.link);
      print(chapterIndex);
    }

    notifyListeners();
  }

  setImageChapter(int chapter) {
    currentImageChapter = loadedChapters[chapter];
    chapterLength = currentImageChapter.count;
    if (chapterList.isNotEmpty) {
      currentChapter = chapterList
          .firstWhere((element) => element.link == currentImageChapter.link);
    }
    notifyListeners();
  }

  clear() {
    currentChapter =
        previousChapter = nextChapter = chapterList = chapterIndex = null;
    currentImageChapter = previousImageChapter = nextImageChapter = null;
    loadedChapters.clear();
  }

  Future<ImageChapter> loadChapter(Chapter chapter, String source) async {
    return await _apiManager.getImages(source, chapter.link);
  }

  addChapter() async {
    if (currentImageChapter == loadedChapters.last) {
      print("Loading Next");

      loadingMore = true;

      ImageChapter c = await loadChapter(chapterList[chapterIndex + 1], source);
      showSnackBarMessage("Next Chapter Loaded!");
      loadedChapters.add(c);

      chapterIndex += 1;
      loadingMore = false;
      print("Append Complete");
      notifyListeners();
    }
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
    page = p + 1;
    notifyListeners();
  }
}
