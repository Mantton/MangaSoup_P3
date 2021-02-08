


class ComicTable {

  static const TABLE = "comics";

  static const COL_ID = "id";
  static const COL_TITLE = "title";
  static const COL_LINK = "link";
  static const COL_THUMBNAIL = "thumbnail";

  static const COL_SOURCE = "source";
  static const COL_SELECTOR = "selector";

  static const COL_IN_LIBRARY = "in_library";
  static const COL_UPDATE_COUNT = "update_count";
  static const COL_CHAPTER_COUNT = "chapter_count";
  static const COL_VIEW_MODE = "view_mode";
  static const COL_IS_NSFW = "nsfw";
  static const COL_DATE_ADDED = "date_added";
  static const COL_RATING = "rating";


  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_TITLE TEXT NOT NULL,
            $COL_LINK TEXT NOT NULL,
            $COL_THUMBNAIL TEXT NOT NULL,
            $COL_SOURCE TEXT NOT NULL,
            $COL_SELECTOR TEXT NOT NULL,
            $COL_IN_LIBRARY INTEGER NOT NULL,
            $COL_CHAPTER_COUNT INTEGER NOT NULL,
            $COL_UPDATE_COUNT INTEGER NOT NULL,
            $COL_VIEW_MODE INTEGER NOT NULL,
            $COL_IS_NSFW INTEGER NOT NULL,
            $COL_RATING INTEGER NOT NULL,
            $COL_DATE_ADDED INTEGER NOT NULL
            )""";


}