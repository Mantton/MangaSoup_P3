import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:provider/provider.dart';

class ChapterList extends StatefulWidget {
  final List chapterList;

  const ChapterList({Key key, @required this.chapterList}) : super(key: key);

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chapters"),
        centerTitle: true,
      ),
      body: Consumer<ComicDetailProvider>(builder: (context, provider, _) {
        List readChapterNames = [];
        List readChapterLinks = [];
        if (provider.history.readChapters != null) {
          readChapterNames =
              provider.history.readChapters.map((m) => m['name']).toList() ??
                  [];
          readChapterLinks =
              provider.history.readChapters.map((m) => m['link']).toList() ??
                  [];
        }


        return Container(
          child:
          ListView.builder(itemBuilder: (BuildContext context, int index) {
            Chapter chapter = Chapter.fromMap(widget.chapterList[index]);
            return ListTile(
              title: Text(
                chapter.name,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: (readChapterNames.contains(chapter.name) ||
                      readChapterLinks.contains(chapter.link))
                      ? Colors.grey[500]
                      : Colors.white,
                ),
              ),
              subtitle: Text(
                chapter.maker ?? "...",
                style: TextStyle(color: Colors.grey[700], fontSize: 15.sp),
              ),
              trailing: Text(
                chapter.date ?? "",
                style: TextStyle(color: Colors.grey[700], fontSize: 15.sp),
              ),
            );
          }),
        );
      }),
    );
  }
}
