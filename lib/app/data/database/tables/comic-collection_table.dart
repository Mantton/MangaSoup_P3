import 'package:mangasoup_prototype_3/app/data/database/tables/collection_table.dart';

import 'comic_table.dart';

class ComicCollectionTable {
  static const TABLE = "comic_collection";

  static const COL_ID = "id";
  static const COL_COMIC_ID = "comic_id";
  static const COL_COLLECTION_ID = "collection_id";



  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_COMIC_ID INTEGER NOT NULL,
            $COL_COLLECTION_ID INTEGER NOT NULL,
            FOREIGN KEY($COL_COLLECTION_ID) REFERENCES ${CollectionTable.TABLE} (${CollectionTable.COL_ID})
            ON DELETE CASCADE,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            )""";
}