
class FavoriteTable{
  static const TABLE = "favorites";

  static const COL_ID = "_id";
  static const COL_TITLE = "title";
  static const COL_LINK = "link";
  static const COL_SOURCE = "source";
  static const COL_SELECTOR = "selector";
  static const COL_VIEWER = "viewer";
  static const COL_CHAPTER_COUNT = "chapter_count";
  static const COL_UPDATE_COUNT = "update_count";


  static String createTableQuery() => """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_TITLE TEXT NOT NULL,
            $COL_LINK TEXT NOT NULL,
            $COL_SELECTOR TEXT NOT NULL,
            $COL_VIEWER INTEGER NOT NULL,
            $COL_CHAPTER_COUNT INTEGER NOT NULL,
            $COL_UPDATE_COUNT INTEGER NOT NULL,
            )""";
}