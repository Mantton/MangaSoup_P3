import 'package:mangasoup_prototype_3/db/tables/collectionTable.dart';
import 'package:mangasoup_prototype_3/dbProvider.dart';

class CollectionQueries {
  static Future<List<Map>> getCollections() async {
    List<Map> maps = await DbProvider.db
        .query(CollectionTable.TABLE, orderBy: CollectionTable.COL_ORDER);
    print(maps);
    return maps;
  }

}
