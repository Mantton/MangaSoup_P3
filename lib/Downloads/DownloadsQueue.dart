import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:provider/provider.dart';

class QueuePage extends StatefulWidget {
  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(builder: (context, provider, _) {
      List<ChapterDownloadObject> objs = provider.downloads
          .where((element) => !element.status.contains("Done"))
          .toList();
      Map grouped =
          groupBy(objs, (ChapterDownloadObject chapter) => chapter.highlight);

      return Container(
        child: objs.isNotEmpty
            ? ListView(
          shrinkWrap: true,
                children: grouped.entries.map((e) {
                  ComicHighlight highlight = e.key;
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
                  title: Text("${chapter.chapter.name}"),
                  subtitle: LinearProgressIndicator(
                    value: chapter.progress / 100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purpleAccent,
                    ),
                    backgroundColor: Colors.black,
                  ),
                  trailing: Column(
                    children: [
                      Container(
                        child: Text(
                          "${(chapter.progress)}%",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700]),
                        ),
                      ),
                      Text("${chapter.status}")
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
              )
            : Center(
                child: Text(
                  "Your Queue is Empty!",
                  style: isEmptyFont,
                ),
              ),
      );
    });
  }
}
