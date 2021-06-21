import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
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

class HistoryHome extends StatefulWidget {
  @override
  _HistoryHomeState createState() => _HistoryHomeState();
}

class _HistoryHomeState extends State<HistoryHome>
    with AutomaticKeepAliveClientMixin {
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
        actions: [
          provider.historyList.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    CupertinoIcons.clear_circled,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => clearHistoryAlert(),
                )
              : Container(),
        ],
      ),
      body: Container(
        child: ListView.separated(
            separatorBuilder: (_, index) => SizedBox(
                  height: 1,
                ),
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
              return Dismissible(
                key: Key(history.id.toString()),
                direction: DismissDirection.endToStart,
                secondaryBackground: slideLeftBackground(),
                background: Container(),
                onDismissed: (d) async => await provider.removeHistory(history),
                child: InkWell(
                  onTap: () {
                    print(comic.title);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileHome(
                          highlight: comic.toHighlight(),
                        ),
                        maintainState: true,
                      ),
                    );
                  },
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.fromLTRB(3, 3, 3, 0),
                    child: Card(
                      color: Color.fromRGBO(15, 15, 15, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SoupImage(
                                url: comic.thumbnail,
                                referer: comic.referer,
                                fit: BoxFit.fitWidth,
                                sourceId: comic.sourceSelector,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(left: 3),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 6,
                                    child: Text(
                                      comic.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "lato",
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Flexible(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: AutoSizeText(
                                            comic.source,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: "lato",
                                              color: Colors.grey[700],
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: AutoSizeText(
                                            DateFormat('yyyy-MM-dd')
                                                .format(history.lastRead),
                                            style: TextStyle(
                                              fontFamily: "lato",
                                              color: Colors.grey[700],
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () async =>
                                    await pushToReader(comic, chapter),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.play,
                                      color: Colors.green,
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        "Chapter ${chapter.generatedChapterNumber}${chapter.lastPageRead == null || chapter.lastPageRead == 0 ? "" : ", Page ${chapter.lastPageRead}"}",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      margin: EdgeInsets.all(4),
      color: Colors.redAccent,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
            Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  clearHistoryAlert() async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Clear All History"),
        content: Text("Are you sure you want to clear all history?"),
        actions: [
          PlatformDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: Text("Proceed"),
            onPressed: () async {
              Navigator.pop(context); // Remove dialog
              showLoadingDialog(context); // Loading Dialog
              try {
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .clearHistory();
                Navigator.pop(context); // Remove Loading dialog
                showSnackBarMessage("History Cleared!");
              } catch (err) {
                Navigator.pop(context); // Remove Loading dialog
                showSnackBarMessage("An error occurred", error: true);
              }
            },
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );
  }

  pushToReader(Comic comic, ChapterData chapterData) async {
    try {
      showLoadingDialog(context);

      Map data = await Provider.of<DatabaseProvider>(context, listen: false)
          .generate(comic.toHighlight());
      Profile profile = data['profile'];
      int id = data['id'];
      int index = 0;
      List<Chapter> chapters = [];
      if (profile.chapters != null) {
        index = profile.chapters
            .indexWhere((element) => element.link == chapterData.link);
        if (index < 0) {
          throw "Bad State, Unreachable";
        }
        chapters = profile.chapters;
      } else {
        Chapter chapter =
            Chapter("Chapter 1", profile.link, "", profile.selector);
        chapter.generatedNumber = 1.0;
        chapters.add(chapter);
      }

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderHome(
            chapters: chapters,
            initialChapterIndex: index,
            selector: profile.selector,
            source: profile.source,
            comicId: id,
            preloaded: false,
            preloadedChapter: null,
            initialPage: chapterData.lastPageRead,
          ),
          fullscreenDialog: true,
        ),
      );
    } catch (err) {
      Navigator.pop(context);
      showSnackBarMessage(err.toString(), error: true);
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
