import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/ViewedDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';

class ViewHistoryProvider with ChangeNotifier {
  List<ViewHistory> history = List();
  List links = List();
  ViewHistoryManager _manager = ViewHistoryManager();
  Future<bool> init() async {
    history = await _manager.getAll();
    history.forEach((element) {
      links.add(element.highlight.link);
    }); // get links to list

    notifyListeners();
    return true;
  }

  bool viewed(ComicHighlight comic) {

    return history.any((element) => element.highlight.link == comic.link);

  }

  addToHistory(ComicHighlight comic) async {
    DateTime logTime = DateTime.now().toLocal();
    if (viewed(comic)) {
      // Update Check Date
      int index =
          history.indexWhere((element) => element.highlight.link == comic.link);
      history[index].timeViewed = logTime; // Update Time viewed
      await _manager.updateByID(history[index]); // Update Object in DB
    } else {
      // Add to History
      ViewHistory toAdd = ViewHistory(null, comic, logTime);
      toAdd = await _manager.save(toAdd); // Saves History and gives it an ID
      history.add(toAdd); // Add to Provider History Object
    }
    notifyListeners(); // Notify consumers of changes and rebuild
  }

  removeFromHistory(ViewHistory comic) async {
    await _manager.deleteByID(comic.id); // delete from db
    history.remove(comic); // remove from history object
    notifyListeners(); // Notify consumers of changes and rebuild
  }

  clearHistory() async {
    // Clear View History
    await _manager.clear();
    history.clear();
    notifyListeners();
  }
}
