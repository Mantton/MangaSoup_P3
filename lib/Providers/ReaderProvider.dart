import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';

class ReaderProvider with ChangeNotifier {
  int page = 0;
  Chapter selectedChapter;
  int readerMode = 1;

  Map readerModeOptions = {
    0: "Manga",
    1: "Webtoon",
    2: "Paged Vertical",
    3: "Continuous Vertical"
  };

  setReaderMode(int mode) {
    readerMode = mode;
    notifyListeners();
  }
}
