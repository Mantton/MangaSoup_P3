import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/models/task_model.dart';
import 'package:provider/provider.dart';

import '../downloads_testing.dart';

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
          itemBuilder: (_, index) => Container(
            child: ComicDownloadBlock(
              provider: db,
              comic:
                  db.comics.firstWhere((element) => keys[index] == element.id),
              chapts: sorted[keys[index]],
            ),
          ),
          separatorBuilder: (_, index) => SizedBox(
            height: 7,
          ),
          itemCount: keys.length,
        ),
      );
    });
  }
}

class ComicDownloadBlock extends StatelessWidget {
  final DatabaseProvider provider;
  final Comic comic;
  final List<ChapterDownload> chapts;

  const ComicDownloadBlock({Key key, this.provider, this.comic, this.chapts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ChapterData> chapterData = provider.chapters
        .where((e) => chapts.map((k) => k.chapterId).contains(e.id))
        .toList();
    chapterData.sort(
        (a, b) => b.generatedChapterNumber.compareTo(a.generatedChapterNumber));
    var dir = chapts.first.saveDir.split(comic.title)[0] + comic.title;
    var size = dirStatSync(dir)["size"];
    return ExpansionTile(
      leading: FittedBox(
        child: SoupImage(
          url: comic.thumbnail,
        ),
      ),
      title: Text(
        comic.title,
        style: notInLibraryFont,
      ),
      subtitle: Text(
        comic.source + "\n$size MB, ${chapts.length} Chapter(s)",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      children: List.generate(
        chapterData.length,
        (i) {
          var data = chapterData[i];
          var x = chapts.firstWhere((element) => element.chapterId == data.id);
          var s = dirStatSync(x.saveDir);
          return ListTile(
            title: Text(data.title),
            trailing: Text(
              "${s['count']} Images(s), ${s['size']} MB",
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
