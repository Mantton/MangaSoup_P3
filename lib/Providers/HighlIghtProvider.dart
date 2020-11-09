import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';

class ComicHighlightProvider with ChangeNotifier {
  ComicHighlight highlight;

  loadHighlight(ComicHighlight hl) async {
    highlight = hl;
    notifyListeners();
  }
}
