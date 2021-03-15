import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_table.dart';

import 'comic_table.dart';

class ChapterDownloadsTable {
  static const TABLE = "downloads";
  static const COL_ID = 'id';
  static const COL_COMIC_ID = "comic_id";
  static const COL_CHAPTER_ID = "chapter_id";

  //Strings
  static const COL_SAVE_DIR = "saved_dir";
  static const COL_CHAPTER_URL = "chapter_url";
  static const COL_PROGRESS = "progress";

  //ints
  static const COL_STATUS = "status";
  static const COL_IMAGE_COUNT = "count";

  //Lists
  static const COL_TASKS = "task_ids";
  static const COL_IMAGE_LINKS = "image_links";

  static String createTableQuery() => """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_COMIC_ID INTEGER NOT NULL,
            $COL_CHAPTER_ID INTEGER NOT NULL,
            $COL_STATUS INTEGER NOT NULL,
            $COL_IMAGE_COUNT INTEGER NOT NULL,
            $COL_SAVE_DIR TEXT NOT NULL,
            $COL_CHAPTER_URL TEXT NOT NULL,
            $COL_PROGRESS TEXT NOT NULL,
            $COL_TASKS TEXT NOT NULL,
            $COL_IMAGE_LINKS TEXT NOT NULL,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            FOREIGN KEY($COL_CHAPTER_ID) REFERENCES ${ChapterTable.TABLE} (${ChapterTable.COL_ID})
            ON DELETE CASCADE
            )""";
}
