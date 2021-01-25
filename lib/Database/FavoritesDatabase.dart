import "dart:io" as io;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesManager {
  //DB Fields
  static Database _db;
  static const String TABLE = 'Favorites';
  static const String DB_NAME = 'userFavorites.db';

  // Favorites Field

  // Important
  static const String ID = 'id';
  static const String LINK = 'link';
  static const String HIGHLIGHT = 'comicHighlight';
  static const String COLLECTION = "collection";

  // Check for Update Fields
  static const String CHAPTER_COUNT = 'chapterCount';
  static const String UPDATE_COUNT = "updateCount";

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
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT ,$LINK TEXT, $HIGHLIGHT TEXT, $COLLECTION TEXT, $CHAPTER_COUNT INTEGER, $UPDATE_COUNT INTEGER);");
  }

  Future<Favorite> save(Favorite fav) async {
    var dbClient = await db;
    fav.id = await dbClient.insert(TABLE, fav.toMap());
    debugPrint("Saved : ${fav.id}");
    return fav;
  }

  Future<bool> updateBulk(List<Favorite> favorites) async {
    for (Favorite fav in favorites) {
      await updateByID(fav);
    }
    return true;
  }

  Future<bool> removeBulk(List<Favorite> favorites) async {
    for (Favorite fav in favorites) {
      await deleteByID(fav.id);
    }
    return true;
  }

  Future<int> deleteByID(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: "$ID = ?", whereArgs: [id]);
  }

  Future<int> deleteByLink(String link) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: "$LINK = ?", whereArgs: [link]);
  }

  Future<int> updateByID(Favorite fav) async {
    var dbClient = await db;
    return await dbClient
        .update(TABLE, fav.toMap(), where: '$ID = ?', whereArgs: [fav.id]);
  }

  Future clear() async {
    var dbClient = await db;
    await dbClient.execute('delete from ' + TABLE);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<List> getCollections() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    Map sorted =
        groupBy(queryResult, (obj) => obj['collection']); // Group By Collection
    return sorted.keys.toList();
  }

  Future<Map> getSortedFavorites() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    List<Favorite> favorites = [];
    queryResult.forEach((element) {
      favorites.add(Favorite.fromMap(element));
    });
    Map sorted = groupBy(
        favorites, (Favorite obj) => obj.collection); // Group By Collection
    return sorted;
  }

  /// FOR UPDATES CHECKING
  Future<List<Favorite>> getUpdateEnabledFavorites() async {
    var dbClient = await db;
    SharedPreferences _pref = await SharedPreferences.getInstance();
    List updateEnabledCollections =
        _pref.getStringList("uec") ?? []; // UEC --> Update Enabled Collections
    print(updateEnabledCollections);
    List<Map> queryResult = await dbClient.query(TABLE);
    List<Favorite> favorites = [];

    Map sorted = groupBy(
      queryResult,
          (obj) => updateEnabledCollections.contains(obj['collection']),
    );

    // print(sorted);
    List<Map> favMaps = sorted[true] ?? [];
    favMaps.forEach((element) {
      favorites.add(Favorite.fromMap(element));
    });
    return favorites;
  }

  Future<List<Favorite>> getAll() async {
    var dbClient = await db;
    List<Map> queryResult = await dbClient.query(TABLE);
    List<Favorite> favorites = [];
    queryResult.forEach((element) {
      favorites.add(Favorite.fromMap(element));
    });
    return favorites;
  }

  Future<Favorite> isFavorite(String link) async {
    var dbClient = await db;
    List<Map> queryResult =
    await dbClient.query(TABLE, where: "$LINK = ?", whereArgs: [link]);
    if (queryResult == null || queryResult.length == 0)
      return null;
    else
      return Favorite.fromMap(queryResult[0]);
  }
}
