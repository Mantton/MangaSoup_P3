import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/comic-collection_table.dart';
import 'package:sqflite/sqflite.dart';

class ComicCollectionQueries {
  Database db;
  ComicCollectionQueries(this.db);

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

  Future<List<ComicCollection>> insertForComic(
      {@required List<Collection> collections, int comicId}) async {

    List<ComicCollection> newC = List();
    for (Collection collection in collections) {
      ComicCollection c =
          ComicCollection(comicId: comicId, collectionId: collection.id);
      c = await insert(c);
      newC.add(c);
    }
    return newC;
  }

  // Set for one

  Future<ComicCollection> insert(ComicCollection comicCollection) async {
    comicCollection.id =
        await db.insert(ComicCollectionTable.TABLE, comicCollection.toMap());

    return comicCollection;
  }

  // Delete Categories
  deleteForComic(List<Comic> comics) async {
    for (Comic comic in comics) {
      await db.delete(ComicCollectionTable.TABLE,
          where: "${ComicCollectionTable.COL_COMIC_ID} = ?",
          whereArgs: [comic.id]);
    }
  }

  deleteComicCollection(ComicCollection c)async{
    await db.delete(ComicCollectionTable.TABLE, where: "${ComicCollectionTable.COL_ID} = ?", whereArgs: [c.id]);
  }

  // Set for multiple
  setCollections(List<ComicCollection> collections, List<Comic> comics) async {
    await deleteForComic(comics);
    for (ComicCollection collection in collections) {
      await insert(collection);
    }
  }

  setCollectionsNonBatch(List<Collection> collections, int comicId)async{
    Comic comic = Comic();
    comic.id = comicId;
    await deleteForComic([comic]);
    await insertForComic(collections: collections, comicId: comicId);
  }
}
