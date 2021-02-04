import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_table.dart';

import 'comic_table.dart';

class HistoryTable{

  static const TABLE = "history";
  static const COL_ID = 'id';
  static const COL_COMIC_ID = "comic_id";
  static const COL_LAST_READ = "last_read";
  static const COL_CHAPTER_ID = "chapter_id";

  static String createTableQuery()=>
      """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_COMIC_ID INTEGER NOT NULL,
            $COL_CHAPTER_ID INTEGER NOT NULL,
            $COL_LAST_READ INTEGER NOT NULL,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            FOREIGN KEY($COL_CHAPTER_ID) REFERENCES ${ChapterTable.TABLE} (${ChapterTable.COL_ID})
            ON DELETE CASCADE
            )""";

}