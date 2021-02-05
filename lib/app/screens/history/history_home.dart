import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryHome extends StatefulWidget {
  @override
  _HistoryHomeState createState() => _HistoryHomeState();
}

class _HistoryHomeState extends State<HistoryHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (BuildContext context, provider, _) =>
          provider.historyList.isNotEmpty ? home(provider) : emptyLibrary(),
    );
  }

  Widget home(DatabaseProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
            itemCount: provider.historyList.length,
            itemBuilder: (BuildContext context, int index) {
              List<History> sorted = List.of(provider.historyList);
              sorted.sort((a, b) => a.lastRead.compareTo(b.lastRead));
              History history = sorted.reversed.toList()[index];
              Comic comic = provider.retrieveComic(history.comicId);
              ChapterData chapter;
              try{
                chapter = provider.retrieveChapter(history.chapterId);
              }catch(E){

              }
              if (chapter == null)
                return Container();
              else return Container(
                color:Color.fromRGBO(15, 15, 15, 1.0),
                height: 110.h,
                margin: EdgeInsets.only(bottom: 5.w),
                padding: EdgeInsets.all(5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          children: [
                            SoupImage(
                              url: comic.thumbnail,
                              referer: comic.referer,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: EdgeInsets.only(left: 2.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              comic.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 17.sp,
                              style: TextStyle(
                                fontFamily: "lato",
                                fontSize: 20.sp,
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  "Chapter ${chapter.generatedChapterNumber}${chapter.lastPageRead == null || chapter.lastPageRead == 0 ? "" : ", Page ${chapter.lastPageRead}"}",
                                  style: TextStyle(color: Colors.blueGrey, fontSize: 15.sp),
                                ),
                                AutoSizeText(
                                  comic.source,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "lato",
                                    fontSize: 15.sp,
                                  ),
                                ),
                                AutoSizeText(
                                  DateFormat('yyyy-MM-dd')
                                      .format(history.lastRead),
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.play_arrow,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileHome(
                                    highlight: comic.toHighlight(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.delete_simple,
                                color: Colors.redAccent,
                              ),
                              onPressed: ()async{
                                await provider.removeHistory(history);
                              } ,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget emptyLibrary() {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Text(
            "Your View History is currently empty",
            style: isEmptyFont,
          ),
        ),
      ),
    );
  }
}
