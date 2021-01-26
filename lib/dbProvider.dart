import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/db/tables/favoriteCollectionTable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import "dart:io" as io;

import 'db/tables/collectionTable.dart';
import 'db/tables/favoriteTable.dart';

class DbProvider with ChangeNotifier {
  static const DB_NAME = "mangasoup.db";
  static const DB_VERSION = 1;
  static Database db;

  initDB() async {
    // Init on Start Up
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    var database =
        await openDatabase(path, version: DB_VERSION, onCreate: _onCreate);
    return database;
  }

  onLaunch() async {
    db = await initDB();
  }

  _onCreate(Database db, int version) async {
    // Create Required Tables
    await db.execute(CollectionTable.createTableQuery()); // Create Collections
    await db.execute(FavoriteTable.createTableQuery()); // Create Favorites
    await db.execute(
        FavoriteCollectionTable.createTableQuery()); // Favorite Collections
  }
}
