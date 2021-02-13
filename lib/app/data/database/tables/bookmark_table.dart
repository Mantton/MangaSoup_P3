import 'comic_table.dart';

class BookMarkTable{
  static const TABLE = "bookmarks";

  static const COL_ID = "id";
  static const COL_PAGE = "page";
  static const COL_COMIC_ID = "comic_id";
  static const COL_C_LINK = "chapter_link";
  static const COL_C_NAME = 'chapter_name';



  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_C_NAME TEXT NOT NULL,
            $COL_C_LINK TEXT NOT NULL,
            $COL_COMIC_ID INTEGER NOT NULL,
            $COL_PAGE INTEGER NOT NULL,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            )""";

}