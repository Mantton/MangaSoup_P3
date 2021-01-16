import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class UpdateManager {
  ApiManager _apiManager = ApiManager();
  FavoritesManager _favoritesManager = FavoritesManager();

  backgroundUpdate() {}

  Future<int> checkForUpdate() async {
    print("In Function");
    // Get Sorted Favorites
    int updateCount = 0;
    List<Favorite> holder = await _favoritesManager.getUpdateEnabledFavorites();

    if (holder.isEmpty){
      return updateCount;
    }

    for (Favorite favorite in holder) {
      ComicHighlight highlight = favorite.highlight;
      ComicProfile _profile;
      try {
        _profile =
            await _apiManager.getProfile(highlight.selector, highlight.link);
        print("Retrieved ${highlight.title} from ${highlight.selector}");
      } catch (e) {
        // on API Error, Skip.
        print("$e");
        continue;
      }

      if (_profile.containsBooks) {
        // Contains books
        _profile.chapterCount = 0;
        for (Map bk in _profile.books) {
          Book book = Book.fromMap(bk);
          _profile.chapterCount += book.generatedLength ?? book.chapters.length;
        }
      }

      int delta = _profile.chapterCount - favorite.chapterCount;
      if (delta <= 0) // If no new updates
        continue;

      // Else Do Update Count Logic
      favorite.updateCount = delta;
      try {
        await _favoritesManager.updateByID(favorite);
        updateCount++;
      } catch (e) {
        // If an error occurs when updating the DB
        continue;
      }
    }

    if (updateCount > 0) favoritesStream.add("Update");

    print("Update Check done");
    return updateCount;
  }
}
