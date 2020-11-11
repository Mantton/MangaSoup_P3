import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "dart:io" as io;
import 'package:path_provider/path_provider.dart';

class ViewHistoryManager {
  static Database _db;
  static const String  TABLE = 'ViewHistory';
  static const String  DB_NAME = 'viewHistory.db';

  // Favorites Field

  // Important
  static const String ID = 'id';
  static const String LINK = 'link';
  static const String HIGHLIGHT = 'comicHighlight';

  // Specific
  static const String TIME_VIEWED = 'time_viewed';

  Future<Database> get db async {
    print("starting");
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    print("Creating");

    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT ,$LINK TEXT, $HIGHLIGHT TEXT, $TIME_VIEWED TEXT);");
  }

  Future<ViewHistory> save(ViewHistory historyInput) async {
    var dbClient = await db;
    historyInput.id = await dbClient.insert(TABLE, historyInput.toMap());
    debugPrint("Saved H : ${historyInput.id}");
    return historyInput;
  }

  Future<int> deleteByID(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: "$ID = ?", whereArgs: [id]);
  }

  Future<int> deleteByLink(String link) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: "$LINK = ?", whereArgs: [link]);
  }

  Future<int> updateByID(ViewHistory comicHistory) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, comicHistory.toMap(),
        where: '$ID = ?', whereArgs: [comicHistory.id]);
  }

  Future clear() async {
    var dbClient = await db;
    await dbClient.execute('delete from ' + TABLE);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<List<ViewHistory>> getAll() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    List<ViewHistory> history = [];
    queryResult.forEach((element) {
      history.add(ViewHistory.fromMap(element));
    });
    return history;
  }

  Future<List<ComicHighlight>> getHighlights() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    List<ComicHighlight> history = [];
    queryResult.forEach((element) {
      history.add(ComicHistory.fromMap(element).highlight);
    });
    return history;
  }

  Future<ViewHistory> checkIfInitialized(String link) async {
    var dbClient = await db;
    List<Map> queryResult =
        await dbClient.query(TABLE, where: "$LINK = ?", whereArgs: [link]);
    if (queryResult == null || queryResult.length == 0)
      return null;
    else
      return ViewHistory.fromMap(queryResult[0]);
  }
}
