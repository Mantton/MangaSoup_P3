import 'package:mangasoup_prototype_3/app/data/database/manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic_table.dart';
import 'package:sqflite/sqflite.dart';

class ComicQuery {
  Database db = DatabaseTestManager.db;

  /// Queries
  /// get comics in library
  /// get comic with id, link or title
  Future<List<Comic>> getLibrary() async {
    List<Map> queryMaps = await db.query(ComicTable.TABLE,
        where: "${ComicTable.COL_IN_LIBRARY} = ?", whereArgs: [1]);
    List<Comic> comics = queryMaps.map((map) => Comic.fromMap(map)).toList();
    return comics;
  }

  Future<Comic> addComic(Comic comic) async {
    comic.id = await db.insert(ComicTable.TABLE, comic.toMap());
    return comic;
  }

  Future<Comic> updateComic(Comic comic) async {
    int updatedId =  await db
        .update(ComicTable.TABLE, comic.toMap(), where: '${ComicTable.COL_ID} = ?', whereArgs: [comic.id]);
    print("Updated Entry No.$updatedId");
    return comic;
  }

  Future<bool> reset() async {
    await db.execute('delete from ' + ComicTable.TABLE);
    return true;
  }
}
