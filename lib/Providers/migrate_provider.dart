import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';

class MigrateProvider with ChangeNotifier {
  Profile current;
  Profile destination;
  bool canMigrate = false;

  init() {
    current = null;
    destination = null;
    canMigrate = false;
  }

  setProfile(Profile p, bool isDestination) {
    if (isDestination)
      destination = p;
    else
      current = p;
    canMigrateLogic();
    notifyListeners();
  }

  canMigrateLogic() {
    if (current != null && destination != null) {
      // Current and Destination have data
      if (current.chapters != null && destination.chapters != null) {
        if (current.chapterCount != null && destination.chapterCount != null) {
          // Chapters have information
          canMigrate = true;
        } else
          canMigrate = false;
      } else
        canMigrate = false;
    } else
      canMigrate = false;
    notifyListeners();
  }
}
