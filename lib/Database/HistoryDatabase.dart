import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "dart:io" as io;
import 'package:path_provider/path_provider.dart';

class HistoryManager {
  static Database _db;
  static const String TABLE = 'History';
  static const String DB_NAME = 'database2.db';

  // Favorites Field

  // Important
  static const String ID = 'id';
  static const String LINK = 'link';
  static const String HIGHLIGHT = 'comicHighlight';

  // Specific
  static const String READ_CHAPTERS = 'readChapters';
  static const String LAST_STOP = 'lastStop';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT ,$LINK TEXT, $HIGHLIGHT TEXT, $READ_CHAPTERS TEXT, $LAST_STOP TEXT)");
  }

  Future<ComicHistory> save(ComicHistory historyInput) async {
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

  Future<int> updateByID(ComicHistory comicHistory) async {
    var dbClient = await db;
    return await dbClient
        .update(TABLE, comicHistory.toMap(), where: '$ID = ?',
        whereArgs: [comicHistory.id]);
  }

  Future clear() async {
    var dbClient = await db;
    await dbClient.execute('delete from ' + TABLE);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<List<ComicHistory>> getAll() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    List<ComicHistory> history = [];
    queryResult.forEach((element) {
      history.add(ComicHistory.fromMap(element));
    });
    return history;
  }

  Future<ComicHistory> checkIfInitialized(String link) async {
    var dbClient = await db;
    List<Map> queryResult =
    await dbClient.query(TABLE, where: "$LINK = ?", whereArgs: [link]);
    if (queryResult == null || queryResult.length == 0)
      return null;
    else
      return ComicHistory.fromMap(queryResult[0]);
  }

}
