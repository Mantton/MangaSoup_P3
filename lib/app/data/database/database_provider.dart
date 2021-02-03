import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/chapter_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/history_queries.dart';
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
    _db = await DatabaseTestManager.initDB();
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

  /// COMICS
  Future<int> evaluate(Comic comic) async {
    // Updates OR Adds comics to db

    Comic retrieved = isComicSaved(comic);

    if (retrieved == null) {
      // Save to Lib
      comic = await comicManager.addComic(comic);
      comics.add(comic);
    } else {
      // Update Comic Details
      comic.id = retrieved.id;
      await comicManager.updateComic(comic);
      int index = comics.indexOf(retrieved);
      comics[index] = comic;
    }
    notifyListeners();
    return comic.id;
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
    Collection newCollection = Collection(name: collectionName);
    newCollection.order = collections.length;
    newCollection = await collectionManager.addCollection(newCollection);
    collections.add(newCollection);
    notifyListeners();
    return newCollection;
  }

  // Comic Collections
  batchSetComicCollection(List<Collection> collections, int comicId) async {
    await comicCollectionManager.setCollectionsNonBatch(collections, comicId);
    comicCollections = await comicCollectionManager.getAll();
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
  }

  updateChapterInfo(int page, Chapter chapter) async {
    ChapterData data = checkIfChapterMatch(chapter);
    data.lastPageRead = page;
    int d = chapters.indexWhere((element) => element.id == data.id);
    chapters[d] = data;
    await chapterManager.updateBatch([data]);
    notifyListeners();
  }

  updateHistory(int comicId, int chapterId) async {
    History newHistory = History(comicId: comicId, chapterId: chapterId);

    if (historyList.any((element) => element.comicId == comicId)) {
      historyList[historyList
          .indexWhere((element) => element.comicId == comicId)] = newHistory;
      await historyManager.updateHistory(historyList[
          historyList.indexWhere((element) => element.comicId == comicId)]);
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

  historyLogic(Chapter chapter, int comicId, String source, String selector) async {
    ChapterData data = checkIfChapterMatch(chapter);
    if (data == null){
      await updateFromACS([chapter], comicId, false, source, selector);
      data = checkIfChapterMatch(chapter);
    }

    await updateHistory(comicId,data.id );
  }
}
