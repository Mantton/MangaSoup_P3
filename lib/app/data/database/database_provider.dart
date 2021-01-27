

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

class DatabaseProvider with ChangeNotifier{

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
  ComicCollectionQueries comicCollectionManager ;

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

  testAdd(Comic comic) async {
    // Check if in lib if not add, else update

    comic = await comicManager.addComic(comic);
    comics.add(comic);
    debugPrint("added ${comic.title}");
    notifyListeners();
  }

}