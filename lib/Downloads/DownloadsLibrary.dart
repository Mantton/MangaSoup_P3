import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/Mantton/AndroidStudioProjects/MangaSoup_P3/lib/Screens/Reader/DebugReaders/DebugReader.dart';

class DownloadLibraryPage extends StatefulWidget {
  @override
  _DownloadLibraryPageState createState() => _DownloadLibraryPageState();
}

class _DownloadLibraryPageState extends State<DownloadLibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(builder: (context, provider, _) {
      List<ChapterDownloadObject> objs = provider.downloads
          .where((element) => element.status.contains("Done"))
          .toList();
      Map grouped = groupBy(
          objs,
          (ChapterDownloadObject chapter) =>
              "${chapter.highlight.title}-${chapter.highlight.source}");

      return Container(
        child: objs.isNotEmpty
            ? ListView(
                children: grouped.entries.map((e) {
                  ComicHighlight highlight = e.value[0].highlight;
                  List<ChapterDownloadObject> chapters = e.value;

                  return ExpansionTile(
                    title: Text(
                      "${highlight.title}",
                      style: TextStyle(
                        fontSize: 20.sp,
                      ),
                    ),
                    leading: SoupImage(
                      url: highlight.thumbnail,
                      referer: highlight.imageReferer,
                    ),
                    subtitle: Text(
                      "${highlight.source}",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    children: chapters.map((e) {
                      ChapterDownloadObject chapter = e;
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DebugReader(
                                selector: chapter.highlight.selector,
                                downloaded: true,
                                cdo: chapter,
                              ),
                            ),
                          );
                        },
                        title: Text("${chapter.chapter.name}"),
                        subtitle: chapter.chapter.maker.isNotEmpty
                            ? Text(
                                "${chapter.chapter.maker}",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 17.sp),
                              )
                            : null,
                        trailing: Text(
                          "${chapter.chapter.date}",
                          style: TextStyle(
                              color: Colors.grey[800], fontSize: 17.sp),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              )
            : Center(
                child: Text(
                  "Your Downloads are empty",
                  style: isEmptyFont,
                ),
              ),
      );
    });
  }
}
