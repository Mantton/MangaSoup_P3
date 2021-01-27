import 'package:mangasoup_prototype_3/app/data/database/tables/collection_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic-collection_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:mangasoup_prototype_3/app/data/database/tables/comic_table.dart';

class DatabaseTestManager {
  static Database db;
  static const String DB_NAME = 'mangasoup.db';
  static const int VERSION = 1;

  static initDB() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    db = await openDatabase(path, version: VERSION, onCreate: _onCreate);
  }

  static _onCreate(Database db, int version) async {
    await db.execute(ComicTable.createTableQuery()); // Comic Table
    await db.execute(CollectionTable.createTableQuery()); // Collection Table
    await db.execute(ComicCollectionTable.createTableQuery()); // Comic Collection Table
    print("Database Initialized");
    return db;
  }

}
