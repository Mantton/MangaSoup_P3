import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class UpdateManager {
  ApiManager _apiManager = ApiManager();

  backgroundUpdate() {}

  Future<int> checkForUpdate() async {
    return 1;
    // print("In Function");
    // // Get Sorted Favorites
    // int updateCount = 0;
    // List<Favorite> holder = await _favoritesManager.getUpdateEnabledFavorites();
    //
    // if (holder.isEmpty){
    //   return updateCount;
    // }
    //
    // for (Favorite favorite in holder) {
    //   ComicHighlight highlight = favorite.highlight;
    //   Profile _profile;
    //   try {
    //     _profile =
    //         await _apiManager.getProfile(highlight.selector, highlight.link);
    //     print("Retrieved ${highlight.title} from ${highlight.selector}");
    //   } catch (e) {
    //     // on API Error, Skip.
    //     print("$e");
    //     continue;
    //   }
    //
    //   int delta = _profile.chapterCount - favorite.chapterCount;
    //   if (delta <= 0) // If no new updates
    //     continue;
    //
    //   // Else Do Update Count Logic
    //   favorite.updateCount = delta;
    //   try {
    //     await _favoritesManager.updateByID(favorite);
    //     updateCount++;
    //   } catch (e) {
    //     // If an error occurs when updating the DB
    //     continue;
    //   }
    // }
    //
    // if (updateCount > 0) favoritesStream.add("Update");
    //
    // print("Update Check done");
    // return updateCount;
  }
}
