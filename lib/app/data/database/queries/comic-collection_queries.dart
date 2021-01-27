import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic-collection_table.dart';
import 'package:sqflite/sqflite.dart';

import '../manager.dart';

class ComicCollectionQueries {
  Database db = DatabaseTestManager.db;

  /*
  * get all
  * get for specific comic
  * set for one
  * set for multiple
  * delete for multiple
  *
  * */

  // get all
  Future<List<ComicCollection>> getAll() async {
    List<Map> queryMap = await db.query(ComicCollectionTable.TABLE);

    List<ComicCollection> comicCollection =
        queryMap.map((e) => ComicCollection.fromMap(e)).toList();

    return comicCollection;
  }

  // for specific comic
  Future<List<ComicCollection>> getForManga({int id}) async {
    List<Map> queryMap = await db.query(ComicCollectionTable.TABLE,
        where: "${ComicCollectionTable.COL_COMIC_ID} = ?", whereArgs: [id]);

    List<ComicCollection> collections =
        queryMap.map((e) => ComicCollection.fromMap(e)).toList();

    return collections;
  }

  // for specific collection
  Future<List<ComicCollection>> getForCollection({int id}) async {
    List<Map> queryMap = await db.query(ComicCollectionTable.TABLE,
        where: "${ComicCollectionTable.COL_COLLECTION_ID} = ?",
        whereArgs: [id]);

    List<ComicCollection> collections =
        queryMap.map((e) => ComicCollection.fromMap(e)).toList();

    return collections;
  }

  // Set for one

  Future<ComicCollection> insert(ComicCollection comicCollection) async {
    comicCollection.id =
        await db.insert(ComicCollectionTable.TABLE, comicCollection.toMap());

    return comicCollection;
  }

  // Delete Categories
  delete(List<Comic> comics) async {
    for (Comic comic in comics) {
      await db.delete(ComicCollectionTable.TABLE,
          where: "${ComicCollectionTable.COL_COMIC_ID} = ?",
          whereArgs: [comic.id]);
    }
  }

  // Set for multiple
  setCollections(List<ComicCollection> collections, List<Comic> comics) async {
    await delete(comics);
    for (ComicCollection collection in collections){
      await insert(collection);
    }
  }

}
