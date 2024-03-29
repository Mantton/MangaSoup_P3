import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_table.dart';
import 'package:sqflite/sqflite.dart';

class ChapterQuery {
  Database db;

  ChapterQuery(this.db);

  // all chapters
  // get all
  Future<List<ChapterData>> getAll() async {
    List<Map> queryMap = await db.query(ChapterTable.TABLE);

    List<ChapterData> chapters =
        queryMap.map((e) => ChapterData.fromMap(e)).toList();
    return chapters;
  }

  Future<void> delete(List<ChapterData> data) async {
    String ids = "(" + data.map((e) => e.id).join(",") + ")";
    ids.replaceAll(",)", ")");
    // await db.delete(ChapterTable.TABLE, where: "${ChapterTable.COL_ID} IN ?", whereArgs: [ids]);
    await db.rawDelete("DELETE FROM manga_chapters WHERE id IN $ids");
  }

  Future<ChapterData> add(ChapterData chapterData) async {
    chapterData.id = await db.insert(ChapterTable.TABLE, chapterData.toMap());
    return chapterData;
  }

  // chapters for specific comic
  Future<List<ChapterData>> getForComic(int comicId) async {
    List<Map> queryMap = await db.query(ChapterTable.TABLE,
        where: "${ChapterTable.COL_COMIC_ID} = ?", whereArgs: [comicId]);

    List<ChapterData> chapters =
        queryMap.map((e) => ChapterData.fromMap(e)).toList();
    return chapters;
  }

  Future<List<ChapterData>> updateBatch(List<ChapterData> chapters) async {
    List<ChapterData> toReturn = List();

    for (ChapterData chapter in chapters) {
      if (chapter.id != null) {
        await db.update(ChapterTable.TABLE, chapter.toMap(),
            where: "${ChapterTable.COL_ID} = ?", whereArgs: [chapter.id]);
        toReturn.add(chapter);

      } else {
        chapter = await add(chapter);
        toReturn.add(chapter);
      }
    }
    return toReturn;
  }
}
