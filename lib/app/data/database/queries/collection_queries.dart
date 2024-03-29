import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/collection_table.dart';
import 'package:sqflite/sqflite.dart';

class CollectionQuery {
  Database db;

  CollectionQuery(this.db);

  Future<Collection> addCollection(Collection newCollection) async {
    newCollection.id =
        await db.insert(CollectionTable.TABLE, newCollection.toMap());

    return newCollection;
  }

  Future<List<Collection>> getCollections() async {
    List<Map> queryMap = await db.query(CollectionTable.TABLE);

    List<Collection> collections =
        queryMap.map((map) => Collection.fromMap(map)).toList();
    return collections;
  }

  Future<Collection> getSingleCollection(int id) async {
    List<Map> queryMap = await db.query(CollectionTable.TABLE,
        where: "${CollectionTable.COL_ID} = ?", whereArgs: [id], limit: 1);

    return Collection.fromMap(queryMap[0]);
  }

  deleteCollection(Collection collection) async {
    await db.delete(CollectionTable.TABLE,
        where: "${CollectionTable.COL_ID} = ?", whereArgs: [collection.id]);
  }

  Future<Collection> renameCollection(Collection collection) async {
    await db.update(CollectionTable.TABLE, collection.toMap(),
        where: "${CollectionTable.COL_ID} = ?", whereArgs: [collection.id]);
    return collection;
  }

  updateCollection(Collection collection) async {
    await db.update(CollectionTable.TABLE, collection.toMap(),
        where: "${CollectionTable.COL_ID} = ?", whereArgs: [collection.id]);
  }

  Future<List<Collection>> reorderCollections(
      List<Collection> collections) async {
    // do order value setting in provider
    for (Collection collection in collections) {
      await db.update(CollectionTable.TABLE, collection.toMap(),
          where: "${CollectionTable.COL_ID} = ?", whereArgs: [collection.id]);
    }
    return collections;
  }
}
