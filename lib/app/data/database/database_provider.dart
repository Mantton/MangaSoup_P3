

import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/history_queries.dart';
import 'models/comic.dart';
import 'models/collection.dart';
import 'manager.dart';

class DatabaseProvider with ChangeNotifier{

  // Provider Variables
  List<Comic> comics = List();
  List<Collection> collections = List();
  List<History> history = List();
  List<ComicCollection> comicCollections = List();

  // Query Managers
  ComicQuery comicManager;
  HistoryQuery historyManager;
  CollectionQuery collectionManager;
  ComicCollectionQueries comicCollectionManager;

  // init

  init() async {
    DatabaseTestManager.initDB();

  }


}