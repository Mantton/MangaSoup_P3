import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/HistoryDatabase.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';

class ComicDetailProvider with ChangeNotifier {
  ComicHighlight highlight;

  // {chapter:"", page:""}
  HistoryManager _manager = HistoryManager();
  ComicHistory history;

  init(ComicHighlight h) async {
    highlight = h;
    history = await _manager.checkIfInitialized(highlight.link);
    if (history == null) {
      // if null add to front of stack
      history = ComicHistory(null, highlight, null, null);
      history = await _manager.save(history);
    } else {
      //remove from stack and add in front
      int x = await _manager.deleteByID(history.id);
      history.id = null;
      history = await _manager.save(history);
    }
    historyStream.add("");
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

  addBulk(List<Map> chapters) async {
    history.readChapters += chapters;
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  removeBulk(List<Map> chapters) async {
    chapters.forEach((element) {
      history.readChapters.remove(element);
    });
    int x = await _manager.updateByID(history);
    historyStream.add("");
    notifyListeners();
  }
}
