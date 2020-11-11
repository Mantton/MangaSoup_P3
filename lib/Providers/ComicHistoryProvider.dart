import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/HistoryDatabase.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';

class ComicDetailProvider with ChangeNotifier {
  ComicHighlight highlight;

  // {chapter:"", page:""}
  HistoryManager _manager = HistoryManager();
  ComicHistory history;

  // todo, implement mangadex mark as read

  init(ComicHighlight h) async {
    highlight = h;
    history = await _manager.checkIfInitialized(highlight.link);
    if (history == null) {
      // if null add to save
      history = ComicHistory(null, highlight, [], null);
      history = await _manager.save(history);
    }
    notifyListeners();
  }

  addToRead(Map chapter) async {
    history.readChapters.add(chapter);
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  removeFromRead(Map chapter) async {
    history.readChapters.remove(chapter);
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  addBulk(List chapters) async {
    history.readChapters += chapters;
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  removeBulk(List chapters) async {
    chapters.forEach((element) {
      history.readChapters.remove(element);
    });
    int x = await _manager.updateByID(history);
    historyStream.add("");
    notifyListeners();
  }

  // markStop(Chapter chapter, int page) async {
  //   history.lastStop = LastStop(chapter, page);
  //   await _manager.updateByID(history);
  //   notifyListeners();
  // }
}
