import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryHome extends StatefulWidget {
  @override
  _HistoryHomeState createState() => _HistoryHomeState();
}

class _HistoryHomeState extends State<HistoryHome> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              try {
                chapter = provider.retrieveChapter(history.chapterId);
              } catch (err) {
                print("HISTORY ERROR: $err\nID:${history.chapterId}");
                print(provider.chapters.map((e) => e.id).toList());
              }
              return GestureDetector(
                onTap: (){
                  print(comic.title);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileHome(
                        highlight: comic.toHighlight(),
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Color.fromRGBO(15, 15, 15, 1.0),
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
                              Text(
                                comic.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "lato",
                                  fontSize: 20,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    "Chapter ${chapter.generatedChapterNumber}${chapter.lastPageRead == null || chapter.lastPageRead == 0 ? "" : ", Page ${chapter.lastPageRead}"}",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 15),
                                  ),
                                  AutoSizeText(
                                    comic.source,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "lato",
                                      fontSize: 15,
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
                                onPressed: () async=> await pushToReader(comic, chapter),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              IconButton(
                                icon: Icon(
                                  CupertinoIcons.delete_simple,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  await provider.removeHistory(history);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
  pushToReader(Comic comic, ChapterData chapterData)async{
    try{
      showLoadingDialog(context);

      Map data = await Provider.of<DatabaseProvider>(context, listen: false).generate(comic.toHighlight());
      Profile profile = data['profile'];
      int id = data['id'];
      int index  = 0 ;
      List<Chapter> chapters = List();
      if (profile.chapters!= null){
        index =  profile.chapters.indexWhere((element) => element.link == chapterData.link);
       chapters = profile.chapters;
      }else {
        Chapter chapter = Chapter(
            "Chapter 1", profile.link, "", profile.selector);
        chapter.generatedNumber = 1.0;
        chapters.add(chapter);
      }

      ImageChapter imageChapter = ImageChapter(
        images:  (chapterData.images)?.map((item) => item as String)?.toList(),
        referer:profile.link,
        link: profile.link,
        source: profile.selector,
        count: chapterData.images.length,
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ReaderHome(
              chapters:chapters,
              initialChapterIndex: index,
              selector:profile.selector,
              source: profile.source,
              comicId: id,
              preloaded: true,
              preloadedChapter: imageChapter,
              initialPage: chapterData.lastPageRead,
            ),
        ),
      );
    }catch(err){
      Navigator.pop(context);
      showSnackBarMessage(err.toString());
    }

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

  @override
  bool get wantKeepAlive => true;
}
