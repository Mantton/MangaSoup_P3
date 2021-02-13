import 'package:mangasoup_prototype_3/app/data/database/models/bookmark.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/bookmark_table.dart';
import 'package:sqflite/sqflite.dart';

class BookMarkQuery {
  Database db;

  BookMarkQuery(this.db);

  // Add
  Future<BookMark> addBookMark(BookMark mark) async {
    int id = await db.insert(BookMarkTable.TABLE, mark.toMap());
    mark.id = id;
    return mark;
  }

  // Delete
  deleteBookMark(BookMark mark) async {
    await db.delete(BookMarkTable.TABLE,
        where: "${BookMarkTable.COL_ID} = ?", whereArgs: [mark.id]);
  }

  // Delete All
  deleteComicBookMarks(int comicId) async {
    await db.delete(BookMarkTable.TABLE,
        where: "${BookMarkTable.COL_COMIC_ID} = ?", whereArgs: [comicId]);
  }

  // Get All
  Future<List<BookMark>> getAllBookMarks() async {
    List<Map> queryMap = await db.query(BookMarkTable.TABLE);

    List<BookMark> bookmarks =
        queryMap.map((e) => BookMark.fromMap(e)).toList();
    return bookmarks;
  }

}
