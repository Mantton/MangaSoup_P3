import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:provider/provider.dart';

class DownloadChaptersPage extends StatefulWidget {
  final List chapterList;

  const DownloadChaptersPage({Key key, @required this.chapterList})
      : super(key: key);

  @override
  _DownloadChaptersPageState createState() => _DownloadChaptersPageState();
}

class _DownloadChaptersPageState extends State<DownloadChaptersPage> {
  List selectedChapters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Chapters"),
        centerTitle: true,
      ),
      body: Container(
        child: Stack(
          children: [
            body(),
            downloadSelector(),
          ],
        ),
      ),
    );
  }

  Widget downloadSelector() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      bottom: (selectedChapters.isNotEmpty) ? 0 : -100.h,
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Container(
            // color: Colors.redAccent,
            // width: 200,
            child: Row(
              children: [
                SoupImage(
                  url: Provider.of<ComicDetailProvider>(context)
                      .highlight
                      .thumbnail,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Provider.of<ComicDetailProvider>(context)
                            .highlight
                            .title,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      Text(
                        "${selectedChapters.length} Chapter(s) selected",
                        style: TextStyle(
                            fontSize: 17.sp, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Spacer(),
                CupertinoButton(
                    child: Text(
                      "Download",
                      style: TextStyle(
                          fontSize: 17.sp, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    return Consumer<ComicDetailProvider>(builder: (context, provider, _) {
      List readChapterNames = [];
      List readChapterLinks = [];
      if (provider.history.readChapters != null) {
        readChapterNames =
            provider.history.readChapters.map((m) => m['name']).toList() ?? [];
        readChapterLinks =
            provider.history.readChapters.map((m) => m['link']).toList() ?? [];
      }
      List chapterList = widget.chapterList;
      return Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Container(
          child: ListView.builder(
              itemCount: chapterList.length,
              itemBuilder: (BuildContext context, int index) {
                Chapter chapter = Chapter.fromMap(chapterList[index]);
                return Container(
                  height: 70.h,
                  child: ListTile(
                    onTap: () {
                      if (!selectedChapters.contains(chapterList[index])) {
                        setState(() {
                          selectedChapters.add(chapterList[index]);
                        });
                      } else {
                        setState(() {
                          selectedChapters.remove(chapterList[index]);
                        });
                      }
                    },
                    title: Text(
                      chapter.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: (readChapterNames.contains(chapter.name) ||
                                readChapterLinks.contains(chapter.link))
                            ? Colors.grey[700]
                            : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      chapter.maker ?? "...",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15.sp,
                      ),
                    ),
                    trailing: Text(
                      chapter.date ?? "",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15.sp,
                      ),
                    ),
                    leading: Icon(
                      (selectedChapters.contains(chapterList[index]))
                          ? Icons.check
                          : Icons.radio_button_unchecked,
                      color: (selectedChapters.contains(chapterList[index]))
                          ? Colors.purple
                          : Colors.grey,
                    ),
                  ),
                );
              }),
        ),
      );
    });
  }
}
