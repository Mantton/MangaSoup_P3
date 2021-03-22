import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';

class MigrateProvider with ChangeNotifier {
  ComicHighlight current;
  Profile destination;
  bool canMigrate = false;

  init() {
    current = null;
    destination = null;
    canMigrate = false;
  }

  setCurrent(ComicHighlight c) {
    current = c;
    print("current set");
    canMigrateLogic();
    notifyListeners();
  }

  setDestination(Profile p) {
    print("destination set");
    destination = p;
    canMigrateLogic();
    notifyListeners();
  }

  canMigrateLogic() {
    if (current != null &&
        destination != null &&
        destination.chapters != null &&
        destination.chapters.isNotEmpty)
      canMigrate = true;
    else {
      canMigrate = false;
    }
    notifyListeners();
  }
}
