import 'package:mangasoup_prototype_3/app/data/database/tables/history_table.dart';
import 'package:sqflite/sqflite.dart';

import '../manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';

class HistoryQuery {
  Database db = DatabaseTestManager.db;

  Future<History> addHistory(History history) async {
    history.id = await db.insert(HistoryTable.TABLE, history.toMap());
    return history;
  }

  deleteHistory(History history) async {
    await db.delete(HistoryTable.TABLE,
        where: "${HistoryTable.COL_ID} = ?", whereArgs: [history.id]);
  }

  Future<List<History>> getHistory({int limit}) async {
    List<Map> queryMap = await db.query(HistoryTable.TABLE,
        limit: limit, orderBy: HistoryTable.COL_LAST_READ);

    List<History> history = queryMap.map((e) => History.fromMap(e)).toList();
    return history;
  }

  Future<History> updateHistory(History history) async {
    await db.update(HistoryTable.TABLE, history.toMap(),
        where: "${HistoryTable.COL_ID} = ?", whereArgs: [history.id]);
    return history;
  }
}
