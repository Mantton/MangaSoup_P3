import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/downloads.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:provider/provider.dart';

import '../../../../reader/reader_home.dart';

class ChapterTile extends StatelessWidget {
  final History history;
  final ChapterData data;
  final bool similarRead;
  final Chapter chapter;
  final Profile profile;
  final int comicID;

  const ChapterTile({
    Key key,
    this.history,
    this.data,
    this.similarRead,
    this.chapter,
    this.profile,
    this.comicID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, provider, _) {
      ChapterData data = provider.checkIfChapterMatch(chapter);
      ChapterDownload downloadInfo;
      bool historyTarget = false;
      if (data != null) {
        downloadInfo = Provider.of<DatabaseProvider>(context)
            .chapterDownloads
            .firstWhere((element) => element.chapterId == data.id,
                orElse: () => null);
        if (history != null) historyTarget = (history.chapterId == data.id);
      }

      TextStyle readFont = TextStyle(
        color: similarRead ? Colors.grey[800] : Colors.white,
      );
      return ListTile(
        title: Text(chapter.name, style: readFont),
        subtitle: chapter.maker.isNotEmpty
            ? Text(
                chapter.maker,
                style: readFont,
              )
            : null,
        trailing: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Download Info
              (downloadInfo != null)
                  ? DownloadIcon(
                      status: downloadInfo.status,
                    )
                  : Container(),
              // History Info
              historyTarget && data != null
                  ? Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          (data.images.length == 0 ||
                                  data.lastPageRead >= data.images.length)
                              ? "Read"
                              : "Page ${data.lastPageRead}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                          ),
                        )
                      ],
                    )
                  : Container(),

              // Similar Read Info
              similarRead && data == null
                  ? Text(
                      "Similar Read",
                      style: TextStyle(color: Colors.blueGrey[800]),
                    )
                  : Container(),
              // Date
              Text(chapter.date.isNotEmpty?
                chapter.date: " ",
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        selectedTileColor: Colors.grey[900],
        onTap: () => onTap(chapter, data, context),
      );
    });
  }

  onTap(Chapter chapter, ChapterData data, BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderHome(
          selector: profile.selector,
          chapters: profile.chapters,
          initialChapterIndex: profile.chapters.indexOf(chapter),
          comicId: comicID,
          source: profile.source,
          initialPage: data != null ? data.lastPageRead : 1,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class DownloadIcon extends StatelessWidget {
  final MSDownloadStatus status;

  const DownloadIcon({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == MSDownloadStatus.queued)
      return Icon(
        Icons.library_books_outlined,
        color: Colors.blueAccent,
      ); // Waiting API Request
    else if (status == MSDownloadStatus.requested)
      return Icon(
        Icons.cloud_circle_rounded,
        color: Colors.indigoAccent,
      ); // Requesting image
    else if (status == MSDownloadStatus.downloading)
      return Icon(
        Icons.download_sharp,
        color: Colors.purple,
      ); // Downloading
    else if (status == MSDownloadStatus.done)
      return Icon(
        Icons.file_download_done,
        color: Colors.green,
      ); // Done
    else if (status == MSDownloadStatus.error)
      return Icon(
        Icons.error_outline,
        color: Colors.redAccent,
      ); // Error
    else
      return Icon(
        Icons.error_outline,
        color: Colors.amber,
      );
  }
}
