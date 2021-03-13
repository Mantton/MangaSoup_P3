import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/models/task_model.dart';
import 'package:provider/provider.dart';

class DownloadLibrary extends StatefulWidget {
  @override
  _DownloadLibraryState createState() => _DownloadLibraryState();
}

class _DownloadLibraryState extends State<DownloadLibrary> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, db, _) {
      // Sort
      Map<int, List<ChapterDownload>> sorted = groupBy(
          db.chapterDownloads.where((element) => element.status == 3),
          (ChapterDownload obj) => obj.comicId); // Group Comic
      List<int> keys = sorted.keys.toList();
      return Container(
        child: ListView.separated(
            itemBuilder: (_, index) => ExpansionTile(
                  leading: SoupImage(
                    url: db.comics
                        .firstWhere((e) => e.id == keys[index])
                        .thumbnail,
                  ),
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
                      onTap: () => print(sorted[keys[index]][i].links),
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
