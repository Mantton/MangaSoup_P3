import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/chapter_webview.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/dialogs/reader_preferences.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/viewer_gateway.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReaderHome extends StatefulWidget {
  final List<Chapter> chapters;
  final int initialChapterIndex;
  final String selector;
  final String source;
  final int comicId;
  final bool preloaded;
  final ImageChapter preloadedChapter;
  final bool imgur;
  final int initialPage;

  const ReaderHome({
    Key key,
    this.chapters,
    this.initialChapterIndex,
    this.selector,
    this.source,
    this.comicId,
    this.preloaded = false,
    this.preloadedChapter,
    this.imgur = false,
    this.initialPage = 1,
  }) : super(key: key);

  @override
  _ReaderHomeState createState() => _ReaderHomeState();
}

class _ReaderHomeState extends State<ReaderHome> {
  @override
  Widget build(BuildContext context) {
    Chapter target = widget.chapters[widget.initialChapterIndex];
    if (target.openInBrowser) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .historyLogic(target, widget.comicId, widget.source, widget.selector);
      return ChapterWebView(url: target.link);
    } else {
      return ReaderOpener(
        chapters: widget.chapters,
        initialChapterIndex: widget.initialChapterIndex,
        selector: widget.selector,
        source: widget.source,
        comicId: widget.comicId,
        preloaded: widget.preloaded,
        preloadedChapter: widget.preloadedChapter,
        imgur: widget.imgur,
        initialPage: widget.initialPage,
      );
    }
  }
}

class ReaderOpener extends StatefulWidget {
  final List<Chapter> chapters;
  final int initialChapterIndex;
  final String selector;
  final String source;
  final int comicId;
  final bool preloaded;
  final ImageChapter preloadedChapter;
  final bool imgur;
  final int initialPage;

  const ReaderOpener(
      {Key key,
      this.chapters,
      this.initialChapterIndex,
      this.selector,
      this.source,
      this.comicId,
      this.preloaded,
      this.preloadedChapter,
      this.imgur,
      this.initialPage})
      : super(key: key);

  @override
  _ReaderOpenerState createState() => _ReaderOpenerState();
}

class _ReaderOpenerState extends State<ReaderOpener> {
  Future providerInitializer;

  @override
  void initState() {
    providerInitializer = Provider.of<ReaderProvider>(context, listen: false)
        .init(widget.chapters, widget.initialChapterIndex, widget.selector,
            context, widget.comicId, widget.source,
            loaded: widget.preloaded,
            loadedChapter: widget.preloadedChapter,
            imgurAlbum: widget.imgur,
            initPage: widget.initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: providerInitializer,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Scaffold(
              extendBody: true,
              body: ReaderFrame(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "An Error Occurred\n${snapshot.error}\nTap to return to profile",
                  style: notInLibraryFont,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: InkWell(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: LoadingIndicator(),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class ReaderFrame extends StatefulWidget {
  @override
  _ReaderFrameState createState() => _ReaderFrameState();
}

class _ReaderFrameState extends State<ReaderFrame> {
  bool _showControls = false;
  PreloadPageController _pagedController;
  PreloadPageController _doublePagedController;
  ItemScrollController _webtoonController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _pagedController = PreloadPageController(
        initialPage: Provider.of<ReaderProvider>(context, listen: false)
            .initialPageIndex);
    _doublePagedController = PreloadPageController(
        initialPage: Provider.of<ReaderProvider>(context, listen: false)
            .initialPageIndex);
    _webtoonController = ItemScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _pagedController.dispose();
    _doublePagedController.dispose();
  }

  void resetControllers() {
    if (_pagedController.hasClients) _pagedController.jumpToPage(0);

    if (_doublePagedController.hasClients) _doublePagedController.jumpToPage(0);

    if (_webtoonController.isAttached) _webtoonController.jumpTo(index: 0);
    debugPrint("controllers reset");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<ReaderProvider>(context, listen: false)
            .toggleShowControls();
      },
      child: Stack(
        children: [
          plain(),
          ViewerGateWay(
            pagedController: _pagedController,
            webToonController: _webtoonController,
            doublePagedController: _doublePagedController,
          ),
          header(),
          footer(),
        ],
      ),
    );
  }

  Widget plain() => GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Consumer<PreferenceProvider>(builder: (context, provider, _) {
          int p = provider.readerBGColor;
          return Container(
            color: p == 0
                ? Colors.black
                : p == 1
                    ? Colors.white
                    : p == 2
                        ? Colors.grey
                        : p == 3
                            ? Colors.grey[900]
                            : Colors.purple,
          );
        }),
      );

  Widget header() {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return AnimatedPositioned(
        duration: Duration(
          milliseconds: 150,
        ),
        top: provider.showControls ? 0 : -120,
        curve: Curves.easeIn,
        height: 120,
        width: MediaQuery.of(context).size.width,
        child: Container(
          alignment: Alignment.topCenter,
          color: Color.fromRGBO(0, 0, 0, .95),
          padding: EdgeInsets.all(7),
          height: 120,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 55,
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                          width: 50,
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.settings,
                              color: Colors.grey,
                            ),
                            onPressed: () => preferenceDialog(context: context),
                          ))
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 2,
                height: 3,
                color: Colors.grey[900],
              ),
              Expanded(
                child: Container(
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 7,
                        fit: FlexFit.tight,
                        child: Container(
                          child: provider.currentChapterName != null
                              ? Text(
                                  "${provider.currentChapterName}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey[900],
                        thickness: 2,
                        indent: 15,
                        endIndent: 15,
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.bookmark),
                        color: provider.pageBookmarked
                            ? Colors.green
                            : Colors.grey[700],
                        onPressed: () => provider
                            .toggleBookMark(), // add current page to bookmark
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.bubble_left_bubble_right,
                          color: Colors.purple,
                        ),
                        onPressed: () => showSnackBarMessage(
                            "Comments Coming soon!",
                            error: true),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget footer() {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      int mode = Provider.of<PreferenceProvider>(context).readerScrollDirection;
      int pow = Provider.of<PreferenceProvider>(context).readerMode;
      return AnimatedPositioned(
        duration: Duration(milliseconds: 150),
        curve: Curves.ease,
        bottom: provider.showControls ? 0 : -60,
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          color: Color.fromRGBO(0, 0, 0, .95),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      try {
                        showLoadingDialog(context);
                        resetControllers();
                        await provider.moveToChapter(
                            next: (pow == 1)
                                ? (mode == 1)
                                    ? true
                                    : false
                                : false);
                        Navigator.pop(context);
                      } catch (err) {
                        print(err);
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Spacer(),
                Expanded(
                  flex: 8,
                  child: provider.pageDisplayNumber != null
                      ? Text(
                          "${provider.pageDisplayNumber}/${provider.pageDisplayCount}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Lato',
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                ),

                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      try {
                        showLoadingDialog(context);
                        resetControllers();
                        await provider.moveToChapter(
                            next: (pow == 1)
                                ? (mode == 1)
                                    ? false
                                    : true
                                : true);
                        Navigator.pop(context);
                      } catch (err) {
                        print(err);
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
