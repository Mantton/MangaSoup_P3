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

  addToRead(String link) async {
    history.readChapters.add(link);
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  removeFromRead(String link) async {
    history.readChapters.remove(link);
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  addBulk(List<String> links) async {
    history.readChapters += links;
    int x = await _manager.updateByID(history);
    historyStream.add("");

    notifyListeners();
  }

  removeBulk(List<String> links) async {
    links.forEach((element) {
      history.readChapters.remove(element);
    });
    int x = await _manager.updateByID(history);
    historyStream.add("");
    notifyListeners();
  }
}
