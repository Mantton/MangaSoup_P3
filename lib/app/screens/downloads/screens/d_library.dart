import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/downloads.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
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
          db.chapterDownloads
              .where((element) => element.status == MSDownloadStatus.done),
          (ChapterDownload obj) => obj.comicId); // Group Comic
      List<int> keys = sorted.keys.toList();
      return Container(
        child: ListView.separated(
          itemBuilder: (_, index) => Container(
            child: ComicDownloadBlock(
              provider: db,
              comic:
                  db.comics.firstWhere((element) => keys[index] == element.id),
              chapterDownloads: sorted[keys[index]],
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
  final List<ChapterDownload> chapterDownloads;

  const ComicDownloadBlock(
      {Key key, this.provider, this.comic, this.chapterDownloads})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ChapterData> chapterData = provider.chapters
        .where((e) => chapterDownloads.map((k) => k.chapterId).contains(e.id))
        .toList();
    chapterData.sort(
        (a, b) => b.generatedChapterNumber.compareTo(a.generatedChapterNumber));
    var dir = Provider.of<PreferenceProvider>(context).paths +
        chapterDownloads.first.saveDir.split(comic.title)[0] +
        comic.title;
    var size = dirStatSync(dir)["size"];
    return ExpansionTile(
      leading: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: true,
            builder: (_) => ProfileHome(highlight: comic.toHighlight()),
          ),
        ),
        onLongPress: () => longPressTile(context, chapterDownloads),
        child: FittedBox(
          child: SoupImage(
            url: comic.thumbnail,
          ),
        ),
      ),
      title: Text(
        comic.title,
        style: notInLibraryFont,
      ),
      subtitle: Text(
        comic.source + "\n$size MB, ${chapterDownloads.length} Chapter(s)",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      children: List.generate(
        chapterData.length,
        (i) {
          var data = chapterData[i];
          var x = chapterDownloads
              .firstWhere((element) => element.chapterId == data.id);
          var s = dirStatSync(
              Provider.of<PreferenceProvider>(context).paths + x.saveDir);
          return ListTile(
            title: Text(data.title),
            trailing: Text(
              "${s['count']} Image(s), ${s['size']} MB",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReaderHome(
                  selector: data.selector,
                  chapters: chapterData.map((e) => e.toChapter()).toList(),
                  initialChapterIndex: i,
                  comicId: comic.id,
                  source: comic.source,
                  initialPage: data != null ? data.lastPageRead : 1,
                ),
                fullscreenDialog: true,
              ),
            ),
            onLongPress: () => longPressTile(context, [x]),
          );
        },
      ),
    );
  }

  void longPressTile(BuildContext context, List<ChapterDownload> toDelete) {
    showPlatformModalSheet(
      context: context,
      builder: (_) => PlatformWidget(
        cupertino: (_, __) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text("Export"),
              onPressed: () {
                Navigator.pop(context);
                showSnackBarMessage("Planned Feature", error: true);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Delete Download${toDelete.length > 1 ? "s" : ""}"),
              onPressed: () {
                showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                          title: Text("Delete Downloads?"),
                          content: Text(
                            "Delete ${toDelete.length} Chapter(s)?",
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                              isDefaultAction: true,
                            ),
                            CupertinoDialogAction(
                              child: Text("Delete"),
                              onPressed: () {
                                Provider.of<DatabaseProvider>(context,
                                        listen: false)
                                    .deleteDownloads(toDelete);
                                Navigator.pop(context);
                              },
                              isDestructiveAction: true,
                            )
                          ],
                        )).then(
                  (value) => Navigator.pop(context),
                );
              },
              isDestructiveAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
            isDefaultAction: true,
          ),
        ),
      ),
    );
  }
}
