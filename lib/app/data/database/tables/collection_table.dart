class CollectionTable{

  static const TABLE = "collections";

  static const COL_ID = "id";
  static const COL_NAME = "name";
  static const COL_ORDER = "order";

  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_NAME TEXT NOT NULL,
            $COL_ORDER INTEGER NOT NULL
            )""";

}