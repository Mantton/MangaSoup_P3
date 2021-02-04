import 'comic_table.dart';

class ChapterTable{
  static const TABLE = "manga_chapters";

  static const COL_ID = "id";
  static const COL_COMIC_ID = "manga_id";

  static const COL_TITLE = "title";
  static const COL_LINK = "link";
  static const COL_SOURCE = 'source';
  static const COL_SELECTOR = "selector";
  static const COL_GENERATED = "generated_chapter_number";
  static const COL_LAST_PAGE_READ = "last_page_read";
  static const COL_READ = "read";
  static const COL_BOOKMARKED= 'bookmarked';
  static const COL_TIME_ACCESSED = "time_accessed";
  static const COL_IMAGES = "images";


  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_LINK TEXT NOT NULL,
            $COL_TITLE TEXT NOT NULL,
            $COL_SOURCE TEXT NOT NULL,
            $COL_SELECTOR TEXT NOT NULL,
            $COL_IMAGES TEXT NOT NULL,
            $COL_GENERATED TEXT NOT NULL,
            $COL_LAST_PAGE_READ INTEGER NOT NULL,
            $COL_READ INTEGER NOT NULL,
            $COL_BOOKMARKED INTEGER NOT NULL,
            $COL_TIME_ACCESSED INTEGER NOT NULL,
            $COL_COMIC_ID INTEGER NOT NULL,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            )""";

}