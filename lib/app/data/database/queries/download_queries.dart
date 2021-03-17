import 'package:mangasoup_prototype_3/app/data/database/models/downloads.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/chapter_downloads_table.dart';
import 'package:sqflite/sqflite.dart';

class DownloadQuery {
  Database db;

  DownloadQuery(this.db);

  Future<ChapterDownload> addDownload(ChapterDownload download) async {
    download.id =
        await db.insert(ChapterDownloadsTable.TABLE, download.toMap());
    return download;
  }

  deleteDownload(ChapterDownload download) async {
    await db.delete(ChapterDownloadsTable.TABLE,
        where: "${ChapterDownloadsTable.COL_ID} = ?", whereArgs: [download.id]);
  }

  Future<List<ChapterDownload>> getDownloads() async {
    List<Map> queryMap = await db.query(ChapterDownloadsTable.TABLE);

    List<ChapterDownload> history =
        queryMap.map((e) => ChapterDownload.fromMap(e)).toList();
    return history;
  }

  Future<ChapterDownload> updateDownload(ChapterDownload download) async {
    await db.update(ChapterDownloadsTable.TABLE, download.toMap(),
        where: "${ChapterDownloadsTable.COL_ID} = ?", whereArgs: [download.id]);
    return download;
  }
}
