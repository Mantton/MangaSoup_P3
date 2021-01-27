import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:mangasoup_prototype_3/app/data/database/tables/comic_table.dart';

class DatabaseTestManager {
  static Database db;
  static const String DB_NAME = 'mangasoup.db';
  static const int VERSION = 1;

  initDB() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    db = await openDatabase(path, version: VERSION, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute(ComicTable.createTableQuery());
    return db;
  }

}
