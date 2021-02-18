import 'comic_table.dart';

class TrackTable {
  static const TABLE = "tracking";
  static const COL_ID = 'id';
  static const COL_COMIC_ID = "comic_id";
  static const COL_TRACK_TYPE = "tracker_type";
  static const COL_COMIC_TITLE = "comic_title";

  static const COL_MEDIA_ID = "media_id";
  static const COL_SYNC_ID = "sync_id";

  static const COL_LAST_READ = "last_read";
  static const COL_TOTAL_CHAPTER = "total_chapters";
  static const COL_SCORE = "score";
  static const COL_START_DATE = "date_started";
  static const COL_END_DATE = "date_ended";

  static String createTableQuery() => """CREATE TABLE $TABLE(
            $COL_ID INTEGER NOT NULL PRIMARY KEY,
            $COL_COMIC_ID INTEGER NOT NULL,
            $COL_MEDIA_ID INTEGER,
            $COL_TRACK_TYPE INTEGER NOT NULL,
            $COL_SYNC_ID INTEGER,
            $COL_SCORE INTEGER,
            $COL_TOTAL_CHAPTER INTEGER NOT NULL,
            $COL_END_DATE INTEGER,
            $COL_START_DATE INTEGER,
            $COL_COMIC_TITLE TEXT NOT NULL,
            $COL_LAST_READ TEXT,
            FOREIGN KEY($COL_COMIC_ID) REFERENCES ${ComicTable.TABLE} (${ComicTable.COL_ID})
            ON DELETE CASCADE
            )""";
}
