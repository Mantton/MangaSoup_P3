import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/models/task_model.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/chapter_tile.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
          db.chapterDownloads
              .where((element) => element.status != MSDownloadStatus.done),
          (ChapterDownload obj) => obj.comicId); // Group Comic
      List<int> keys = sorted.keys.toList();
      return Container(
        child: ListView.separated(
          itemBuilder: (_, index) => ComicDownloadBlock(
            provider: db,
            comic: db.comics.firstWhere((element) => keys[index] == element.id),
            chapts: sorted[keys[index]],
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
    return ExpansionTile(
      title: Text(
        comic.title,
        style: notInLibraryFont,
      ),
      subtitle: Text(
        comic.source,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      children: List.generate(
        chapterData.length,
        (i) {
          var data = chapterData[i];
          var x = chapts.firstWhere((element) => element.chapterId == data.id);
          return ListTile(
              title: Text(data.title),
              trailing: DownloadQueueStatus(
                data: x,
              ));
        },
      ),
    );
  }
}

class DownloadQueueStatus extends StatelessWidget {
  final ChapterDownload data;

  const DownloadQueueStatus({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: DownloadIcon(
        status: data.status,
      ),
      baseColor: Colors.purple,
      highlightColor: Colors.purpleAccent,
    );
  }
}
