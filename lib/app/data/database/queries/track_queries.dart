import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/database/tables/track_table.dart';
import 'package:sqflite/sqflite.dart';

class TrackQuery {
  Database db;

  TrackQuery(this.db);

  Future<Tracker> addTracker(Tracker tracker) async {
    tracker.id = await db.insert(TrackTable.TABLE, tracker.toMap());
    return tracker;
  }

  deleteTracker(Tracker tracker) async {
    await db.delete(TrackTable.TABLE,
        where: "${TrackTable.COL_ID} = ?", whereArgs: [tracker.id]);
  }

  Future<List<Tracker>> getTrackers() async {
    List<Map> queryMap =
        await db.query(TrackTable.TABLE, orderBy: TrackTable.COL_LAST_READ);

    List<Tracker> trackers = queryMap.map((e) => Tracker.fromMap(e)).toList();
    return trackers;
  }

  Future<Tracker> updateTracker(Tracker tracker) async {
    await db.update(TrackTable.TABLE, tracker.toMap(),
        where: "${TrackTable.COL_ID} = ?", whereArgs: [tracker.id]);
    return tracker;
  }
}
