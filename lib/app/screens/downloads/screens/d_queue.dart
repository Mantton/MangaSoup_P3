
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/models/task_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class DownloadQueue extends StatefulWidget {
  @override
  _DownloadQueueState createState() => _DownloadQueueState();
}

class _DownloadQueueState extends State<DownloadQueue> {
  //Variables

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, db, _) {
      // Sort
      Map<int, List<ChapterDownload>> sorted = groupBy(
          db.chapterDownloads.where((element) => element.status != 3),
          (ChapterDownload obj) => obj.comicId); // Group Comic
      List<int> keys = sorted.keys.toList();
      return Container(
        child: ListView.separated(
            itemBuilder: (_, index) => ExpansionTile(
                  title: Text(
                    db.comics.firstWhere((e) => e.id == keys[index]).title,
                  ),
                  subtitle: Text(
                    db.comics.firstWhere((e) => e.id == keys[index]).source,
                  ),
                  children: List.generate(
                    sorted[keys[index]].length,
                    (i) => ListTile(
                      title: Text(db.chapters
                          .firstWhere(
                              (e) => e.id == sorted[keys[index]][i].chapterId)
                          .title),
                      trailing: CircularPercentIndicator(
                        radius: 45.0,
                        lineWidth: 3.0,
                        percent: sorted[keys[index]][i].progress / 100,
                        progressColor: Colors.purple,
                        backgroundColor: Colors.grey[900],
                        // fillColor: Colors.grey[900],
                      ),
                      onTap: () => print(sorted[keys[index]][i].status),
                    ),
                  ),
                ),
            separatorBuilder: (_, index) => SizedBox(
                  height: 7,
                ),
            itemCount: keys.length),
      );
    });
  }
}
