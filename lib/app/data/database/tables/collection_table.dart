class CollectionTable{

  static const TABLE = "collections";

  static const COL_ID = "id";
  static const COL_NAME = "name";
  static const COL_ORDER = "sort";
  static const COL_UPDATE_ENABLED = "update_enabled";
  static const COL_LIBRARY_SORT = "library_sort";

  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_NAME TEXT NOT NULL,
            $COL_ORDER INTEGER NOT NULL,
            $COL_UPDATE_ENABLED INTEGER NOT NULL,
            $COL_LIBRARY_SORT INTEGER NOT NULL
            )""";

}