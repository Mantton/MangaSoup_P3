
class CollectionTable{
  static const TABLE = "collections"; // Table name

  // Table Fields
  static const COL_ID = "_id";
  static const COL_NAME = "name";
  static const COL_ORDER = "sort";
  static const COL_NSFW = "nsfw";


  static String createTableQuery() => """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_NAME TEXT NOT NULL,
            $COL_ORDER INTEGER NOT NULL,
            $COL_NSFW INTEGER NOT NULL
            )""";

}