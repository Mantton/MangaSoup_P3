import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/history_queries.dart';
import 'package:sqflite/sqflite.dart';
import 'models/comic.dart';
import 'models/collection.dart';
import 'manager.dart';

class DatabaseProvider with ChangeNotifier {
  // Provider Variables
  List<Comic> comics = List();
  List<Collection> collections = List();
  List<History> history = List();
  List<ComicCollection> comicCollections = List();
  Database _db;

  // Query Managers
  ComicQuery comicManager;
  HistoryQuery historyManager;
  CollectionQuery collectionManager;
  ComicCollectionQueries comicCollectionManager;

  // init

  init() async {
    // Init Local DB
    _db = await DatabaseTestManager.initDB();
    comicManager = ComicQuery(_db);
    historyManager = HistoryQuery(_db);
    collectionManager = CollectionQuery(_db);
    comicCollectionManager = ComicCollectionQueries(_db);
    // Load Data into Provider Variables
    comics = await comicManager.getAll();
    collections = await collectionManager.getCollections();
    history = await historyManager.getHistory(limit: 25);
    comicCollections = await comicCollectionManager.getAll();
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

  Future<Collection> createCollection(String collectionName) async {
    Collection newCollection = Collection(name: collectionName);
    newCollection.order = collections.length + 1;
    newCollection = await collectionManager.addCollection(newCollection);
    collections.add(newCollection);
    notifyListeners();
    return newCollection;
  }

  // Comic Collections
  batchSetComicCollection(List<Collection> collections, int comicId) async {
    await comicCollectionManager.setCollectionsNonBatch(collections, comicId);
    comicCollections = await comicCollectionManager.getAll();

    // print(comicCollections.map((e) => e.comicId).toList());
    // List<ComicCollection> newLibraryInputs = await comicCollectionManager
    //     .insertForComic(collections: collections, comicId: comicIc);
    // comicCollections.addAll(newLibraryInputs);
    // print(comicCollections.map((e) => e.comicId).toList());
    // notifyListeners();
  }

  /// Add to Library
  addToLibrary(List<Collection> collections, int comicId) async {
    // Insert to Comic Collections
    batchSetComicCollection(collections, comicId);
    // Change status to in Library
    Comic retrieved = retrieveComic(comicId);
    retrieved.inLibrary = true;
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
}
