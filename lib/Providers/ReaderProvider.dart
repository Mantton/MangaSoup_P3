import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';

class ReaderProvider with ChangeNotifier {
  int page = 0;
  Chapter selectedChapter;
  int readerMode = 1;
  List<ImageChapter> loadedChapters = List();
  Map readerModeOptions = {
    0: "Manga",
    1: "Webtoon",
    2: "Paged Vertical",
    3: "Continuous Vertical"
  };

  setReaderMode(int mode) {
    print("Changing reader mode");
    readerMode = mode;
    notifyListeners();
  }

  initChapter(ImageChapter chapter) {
    loadedChapters.clear();
    loadedChapters.add(chapter);
    notifyListeners();
  }

  addChapter(ImageChapter chapter) {
    loadedChapters.add(chapter);
    notifyListeners();
  }
}
