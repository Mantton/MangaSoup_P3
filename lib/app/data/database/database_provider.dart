import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/chapter_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/history_queries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'manager.dart';
import 'models/collection.dart';
import 'models/comic.dart';

class DatabaseProvider with ChangeNotifier {
  // Provider Variables
  List<Comic> comics = List();
  List<Collection> collections = List();
  List<History> historyList = List();
  List<ComicCollection> comicCollections = List();
  List<ChapterData> chapters = List();
  Database _db;

  // Query Managers
  ComicQuery comicManager;
  HistoryQuery historyManager;
  CollectionQuery collectionManager;
  ComicCollectionQueries comicCollectionManager;
  ChapterQuery chapterManager;
  // init

  init() async {
    // Init Local DB
    _db = await DatabaseManager.initDB();
    comicManager = ComicQuery(_db);
    historyManager = HistoryQuery(_db);
    collectionManager = CollectionQuery(_db);
    comicCollectionManager = ComicCollectionQueries(_db);
    chapterManager = ChapterQuery(_db);
    // Load Data into Provider Variables
    comics = await comicManager.getAll();
    collections = await collectionManager.getCollections();
    historyList = await historyManager.getHistory(limit: 25);
    comicCollections = await comicCollectionManager.getAll();
    chapters = await chapterManager.getAll();
    print("database initialization complete.");
    notifyListeners();
  }

  // GENERATE COMIC
  Future<Map<String, dynamic>> generate(ComicHighlight highlight) async {
    ApiManager _manager = ApiManager();

    /// Get Profile
    try{
      Profile profile = await _manager.getProfile(
        highlight.selector,
        highlight.link,
      );

      Comic generated = Comic(
          title: highlight.title,
          link: highlight.link,
          thumbnail: profile.selector != "hasu"
              ? profile.thumbnail
              : highlight.thumbnail,
          referer: highlight.imageReferer,
          source: highlight.source,
          sourceSelector: highlight.selector,
          chapterCount: profile.chapterCount ?? 0);

      Comic comic = isComicSaved(generated);
      if (comic != null) {
        // UPDATE VALUES HERE
        if (profile.selector != "hasu") comic.thumbnail = profile.thumbnail;
        comic.updateCount = 0;
        comic.chapterCount = profile.chapterCount ?? 0;
      } else
        comic = generated;
      // Evaluate
      int _id = await evaluate(comic);
      return {"profile": profile, "id": _id};
    }
    catch(e){
      if (e is DioError){
        throw "Network Related Error";
      }else{
        print(e);
        throw "Unable to Serialize";
      }

    }

  }

  /// COMICS
  Future<int> evaluate(Comic comic, {bool overWriteChapterCount=true}) async {
    // Updates OR Adds comics to db

    Comic retrieved = isComicSaved(comic);

    if (retrieved == null) {
      // Save to Lib
      comic.dateAdded = DateTime.now();
      comic = await comicManager.addComic(comic);
      comics.add(comic);
    } else {
      // Update Comic Details
      comic.id = retrieved.id;
      comic.dateAdded = retrieved.dateAdded;
      if (!overWriteChapterCount)
        comic.chapterCount = retrieved.chapterCount;
      await comicManager.updateComic(comic);
      int index = comics.indexOf(retrieved);
      comics[index] = comic;
    }
    notifyListeners();
    return comic.id;
  }

  List<Comic> searchLibrary(String query) {
    return comics
        .where(
          (element) =>
              element.inLibrary &&
              element.title.toLowerCase().startsWith(
                    query.toLowerCase(),
                  ),
        )
        .toList();
  }

  Comic retrieveComic(int id) {
    return comics.firstWhere((element) => element.id == id);
  }

  Collection retrieveCollection(int id) {
    return collections.firstWhere((element) => element.id == id);
  }

  ChapterData retrieveChapter(int id) {
    return chapters.firstWhere((element) => element.id == id);
  }

  Comic isComicSaved(Comic comic) {
    try {
      Comic retrieved = comics.firstWhere((element) =>
          element.source == comic.source && comic.link == element.link);
      return retrieved;
    } catch (err) {
      return null;
    }
  }

  /// COLLECTIONS
  bool checkIfCollectionExists(String collectionName) {
    List<Collection> exists = collections
        .where((element) =>
            element.name.toLowerCase() == collectionName.toLowerCase())
        .toList();
    if (exists.isEmpty)
      return false;
    else
      return true;
  }
  clearAllCollection()async{
    // Delete Collections

    List<Collection> toDelete = collections.where((element) => element.id != 1).toList();
    collections.removeWhere((element) => toDelete.contains(element)); // delete from provider object
    print(collections);
    print("Deleted Collections");
    // Delete Comic Collections
    List<ComicCollection>comicCollectionsToDelete = comicCollections.where((element) => toDelete.map((e) => e.id).toList().contains(element.collectionId)).toList();
    comicCollections.removeWhere((element) => comicCollectionsToDelete.contains(element)); // remove comic collections
    print("Deleted Comic Collections");
    // Delete from DB
    toDelete.forEach((element) async => await collectionManager.deleteCollection(element));
    comicCollectionsToDelete.forEach((element) async =>await comicCollectionManager.deleteComicCollection(element));
    print("Updated Database");
    // Re-add Collections under default.
    Collection defaultCollection = collections.firstWhere((element) => element.id== 1 );
    List<Comic> lib = comics.where((element) => element.inLibrary).toList();
    print("Retrieved favorites");
    lib.forEach((element)async =>await batchSetComicCollection([defaultCollection], element.id));
    print("Collection Clear Complete");
    notifyListeners();
  }
  updateCollectionOrder(int initial, int newIndex) async {
    initial++;

    print("initial: $initial\n new:$newIndex");
    if (newIndex < initial) {
      newIndex++;
      // Get Target Collection that is being updated
      Collection target =
          collections.firstWhere((element) => element.order == initial);
      // get affected collections from update
      List<Collection> strays = collections
          .where(
              (element) => element.order >= newIndex && element.order < initial)
          .toList();
      // update affected collections
      strays.forEach((element) {
        int toUpdate = collections.indexOf(element);
        collections[toUpdate].order++;
      });

      // Update provider collections variable
      collections[collections.indexOf(target)].order = newIndex;
    } else {
      // Get Target Collection that is being updated
      Collection target =
          collections.firstWhere((element) => element.order == initial);
      // get affected collections from update
      List<Collection> strays = collections
          .where((element) =>
              element.order <= newIndex && element.order >= initial)
          .toList();
      // update affected collections
      strays.forEach((element) {
        int toUpdate = collections.indexOf(element);
        collections[toUpdate].order--;
      });

      // Update provider collections variable

      collections[collections.indexOf(target)].order = newIndex;
    }
    await collectionManager.reorderCollections(collections);
    notifyListeners();
  }

  Future<Collection> createCollection(String collectionName) async {
    Collection newCollection = Collection(name: collectionName.trim());
    newCollection.order = collections.length;
    newCollection = await collectionManager.addCollection(newCollection);
    collections.add(newCollection);
    print("Name: ${newCollection.name},Initial Order: ${newCollection.order}");
    notifyListeners();
    return newCollection;
  }
  Future<Collection> updateCollection(Collection collection)async{
    int index = collections.indexWhere((element) => element.id == collection.id);
    collections[index] = collection;
    await collectionManager.updateCollection(collection);
    notifyListeners();
    return collection;

  }

  // Comic Collections
  batchSetComicCollection(List<Collection> collections, int comicId) async {
    await comicCollectionManager.setCollectionsNonBatch(collections, comicId);
    comicCollections = await comicCollectionManager.getAll();
    notifyListeners();
  }

  /// Add to Library
  addToLibrary(List<Collection> collections, int comicId,
      {bool remove = false}) async {
    // Insert to Comic Collections
    batchSetComicCollection(collections, comicId);
    // Change status to in Library
    Comic retrieved = retrieveComic(comicId);
    retrieved.inLibrary = (!remove) ? true : false;
    await comicManager.updateComic(retrieved);
    int index = comics.indexOf(retrieved);
    comics[index] = retrieved;
    // Notify
    notifyListeners();
  }

  List<int> getSpecificComicCollectionIds(int comicId) {
    List<ComicCollection> retrieved = comicCollections
        .where((element) => element.comicId == comicId)
        .toList();
    return retrieved.map((e) => e.collectionId).toList();
  }

  List<Comic> getCollectionComics(int id) {
    // get the get comic collections matching given id;

    List<int> requiredIds = comicCollections
        .where((element) => element.collectionId == id)
        .toList()
        .map((e) => e.comicId)
        .toList();

    // get the comic linked to those collections

    List<Comic> requiredComics =
        comics.where((element) => requiredIds.contains(element.id)).toList();
    return requiredComics;
  }

  toggleCollectionUpdate(Collection collection) {
    collection.updateEnabled = !collection.updateEnabled;

    int target =
        collections.indexWhere((element) => element.id == collection.id);
    collections[target] = collection;
    collectionManager.updateCollection(collection);
    notifyListeners();
  }

  Future<int> checkForUpdates() async {
    print("--- CHECKING FOR UPDATE ---");
    int updateCount = 0;
    List<Collection> uec =
        collections.where((element) => element.updateEnabled).toList();

    if (uec.isEmpty) return null;

    for (Collection c in uec) {
      List<ComicCollection> d = comicCollections
          .where((element) => element.collectionId == c.id)
          .toList();

      for (ComicCollection e in d) {
        Comic comic = comics.firstWhere((element) => element.id == e.comicId);
        print(comic.title);
        // calculate if chapter count has increased
        /// CHECK FOR UPDATE LOGIC
        int currentChapterCount = comic.chapterCount;
        // Get Profile of comic

        try {
          Profile profile =
              await ApiManager().getProfile(comic.sourceSelector, comic.link);
          int updatedChapterCount = profile.chapterCount;

          // increase or do nothing about the updated count
          /// UPDATE COUNT LOGIC
          if (updatedChapterCount > currentChapterCount) {
            updateCount++; // increase update count metric

            // Update Comic Data
            comic.chapterCount = updatedChapterCount;
            comic.updateCount = updatedChapterCount - currentChapterCount;
            await evaluate(comic);
          }
        } catch (e) {
          continue;
        }
      }
    }
    print("---DONE CHECKING FOR UPDATE---");
    notifyListeners();
    return updateCount;
  }

  ChapterData checkIfChapterMatch(Chapter chapter) {
    ChapterData implied;
    try {
      implied = chapters.firstWhere((element) =>
          element.generatedChapterNumber == chapter.generatedNumber &&
          element.link == chapter.link);
      return implied;
    } catch (err) {
      return null;
    }
  }

  updateChapterImages(Chapter chapter, List images)async{
    ChapterData data = checkIfChapterMatch(chapter);
    if (data != null){
      data.images = images;
      int d = chapters.indexWhere((element) => element.id == data.id);
      chapters[d] = data;
      await chapterManager.updateBatch([data]);
      notifyListeners();
    }
  }

  bool checkSimilarRead(Chapter chapter, int comicId) {
    bool check = chapters.any((element) =>
        element.read &&
        element.generatedChapterNumber == chapter.generatedNumber &&
        element.mangaId == comicId);
    return check;
  }

  updateFromACS(List<Chapter> incoming, int comicId, bool read, String source,
      String selector) async {
    List<ChapterData> data = List();
    // Chack for matches, update their status to read then add to data
    for (Chapter chapter in incoming) {
      ChapterData append = checkIfChapterMatch(chapter);
      // Check for non matches Create nChapterData objects then append to data
      if (append == null) {
        append = ChapterData(
          title: chapter.name,
          mangaId: comicId,
          link: chapter.link,
          generatedChapterNumber: chapter.generatedNumber,
          source: source,
          selector: selector,
        );
      }
      append.read = read;
      data.add(append);
    }
    data = await chapterManager.updateBatch(data);
    // if in chapters, update
    for (ChapterData obj in data) {
      if (chapters.any((element) => element.id == obj.id))
        chapters[chapters.indexWhere((element) => element.id == obj.id)] = obj;
      else
        chapters.add(obj);
    }
    notifyListeners();
    // MD Sync
    if (selector == "mangadex" && read){
      SharedPreferences.getInstance().then((_prefs) async {
        if (_prefs.getString("mangadex_cookies")!= null){
          // Cookies containing profile exists
          // Sync to MD
          try{
             ApiManager().syncChapters(data.map((e) => e.link).toList(), true);
          }catch(err){
            showSnackBarMessage(err);
          }
        }
      });
    }
  }

  updateChapterInfo(int page, Chapter chapter) async {
    ChapterData data = checkIfChapterMatch(chapter);
    data.lastPageRead = page;
    int d = chapters.indexWhere((element) => element.id == data.id);
    chapters[d] = data;
    await chapterManager.updateBatch([data]);
    notifyListeners();
  }
  updateHistoryFromChapter(int comicId, Chapter chapter, int page){
    updateChapterInfo(page, chapter);
    ChapterData pointed =
    checkIfChapterMatch(chapter);
    updateHistory(comicId, pointed.id);

  }
  updateHistory(int comicId, int chapterId) async {
    if (historyList.any((element) => element.comicId == comicId)) {
      int targetIndex =
          historyList.indexWhere((element) => element.comicId == comicId);

      historyList[targetIndex].chapterId = chapterId;
      historyList[targetIndex].lastRead = DateTime.now();

      await historyManager.updateHistory(historyList[targetIndex]);
      // update
    } else {
      // add
      History newHistory = History(comicId: comicId, chapterId: chapterId);
      newHistory = await historyManager.addHistory(newHistory);
      historyList.add(newHistory);
    }

    notifyListeners();
  }

  removeHistory(History history) async {
    await historyManager.deleteHistory(history);
    historyList.remove(history);
    notifyListeners();
  }

  historyLogic(
      Chapter chapter, int comicId, String source, String selector) async {
    ChapterData data = checkIfChapterMatch(chapter);
    if (data == null) {
      await updateFromACS([chapter], comicId, false, source, selector);
      data = checkIfChapterMatch(chapter);
    }
    await updateHistory(comicId, data.id);
  }
}
