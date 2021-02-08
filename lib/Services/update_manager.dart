import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:sqflite/sqflite.dart';

class UpdateManager {
  ApiManager _apiManager = ApiManager();

  Future<int> checkForUpdateBackGround() async {
    int updateCount = 0; // Number of Updated Comics
    Database _db = await DatabaseManager.initDB(); // Initialize Database
    // Get Update Enabled Collections

    List<Collection> updateEnabledCollections =
        await CollectionQuery(_db).getCollections();
    updateEnabledCollections = updateEnabledCollections.where(
        (element) => element.updateEnabled).toList(); // select only update enabled

    // Get Comics for each uec
    for (Collection collection in updateEnabledCollections) {
      // Get the matching comic collections for the specified collection {id}
      List<ComicCollection> comicCollections =
          await ComicCollectionQueries(_db).getForCollection(id: collection.id);

      for (ComicCollection target in comicCollections) {
        // Get target comic
        Comic comic = await ComicQuery(_db).getComic(target.comicId);

        // calculate if chapter count has increased
        /// CHECK FOR UPDATE LOGIC
        int currentChapterCount = comic.chapterCount;
        // Get Profile of comic

        try {
          Profile profile =
              await _apiManager.getProfile(comic.sourceSelector, comic.link);
          int updatedChapterCount = profile.chapterCount;

          // increase or do nothing about the updated count
          /// UPDATE COUNT LOGIC
          if (updatedChapterCount > currentChapterCount) {
            updateCount++; // increase update count metric

            // Update Comic Data
            comic.chapterCount = updatedChapterCount;
            comic.updateCount = updatedChapterCount - currentChapterCount;
            await ComicQuery(_db).updateComic(comic);
          }
        } catch (e) {
          continue;
        }
      }
    }

    // update UI
    // return update count for notification
    _db.close(); // Close DB
    print("Update Count : $updateCount");
    try{
      bgUpdateStream.add("$updateCount");
      print("added to stream");
    }catch(err){
      print("ERROR\n$err");
    }
    return updateCount;
  }
}
