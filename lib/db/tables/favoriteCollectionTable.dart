
import 'collectionTable.dart';
import 'favoriteTable.dart';

class FavoriteCollectionTable{
  static const TABLE = "favoriteCollections"; // Table name

  // Table Fields
  static const COL_ID = "_id";
  static const COL_FAV_ID = "favorite_id";
  static const COL_COL_ID = "collection_id";


  static String createTableQuery() => """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_FAV_ID TEXT NOT NULL,
            $COL_COL_ID INTEGER NOT NULL,
            FOREIGN KEY($COL_COL_ID) REFERENCES ${CollectionTable.TABLE} (${CollectionTable.COL_ID})
            ON DELETE CASCADE,
            FOREIGN KEY($COL_FAV_ID) REFERENCES ${FavoriteTable.TABLE} (${FavoriteTable.COL_ID})
            ON DELETE CASCADE
            )""";

}