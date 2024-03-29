import 'dart:io' as io;

import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/bookmark_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_downloads_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/collection_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic-collection_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/history_table.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/track_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static Database db;
  static const String DB_NAME = 'mangasoup.db';
  static const int VERSION = 5;

  static initDB() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    db = await openDatabase(path,
        version: VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  static _onCreate(Database db, int version) async {
    await db.execute(ChapterTable.createTableQuery()); // Chapter Table
    await db.execute(ComicTable.createTableQuery()); // Comic Table
    await db.execute(CollectionTable.createTableQuery()); // Collection Table
    await db.execute(
        ComicCollectionTable.createTableQuery()); // Comic Collection Table
    await db.execute(HistoryTable.createTableQuery()); // History Table
    await db.execute(BookMarkTable.createTableQuery()); // BookMark Table
    await db.execute(TrackTable.createTableQuery()); // Tracking Table
    await db
        .execute(ChapterDownloadsTable.createTableQuery()); // Downloads Table

    // Create Default Collection
    await db.insert(CollectionTable.TABLE, Collection.createDefault().toMap());
    print("database created successfully!");
    return db;
  }

  static _onUpgrade(Database db, int oldV, int newV) async {
    // Update Version
    if (oldV < 2) {
      await db.execute(BookMarkTable.createTableQuery()); // BookMark Table
    }
    if (oldV < 3) {
      await db.execute(TrackTable.createTableQuery()); // Tracking Table
    }

    if (oldV < 4) {
      //add unread count
      await db.execute(
          "ALTER TABLE ${ComicTable.TABLE} ADD ${ComicTable.COL_UNREAD_COUNT} INTEGER NOT NULL DEFAULT 0");
    }

    if (oldV < 5) {
      try {
        await db.execute(
            ChapterDownloadsTable.createTableQuery()); // Downloads Table
      } catch (err) {
        print("Oh no");
      }
    }
  }
}
