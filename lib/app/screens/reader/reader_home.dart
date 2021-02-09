import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/chapter_webview.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/viewer_gateway.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      body: FutureBuilder(
        future: providerInitializer,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return ReaderFrame();
          }
          if (snapshot.hasError) {
            return Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Text(
                  (snapshot.error is DioError)
                      ? "Network Error\nTap to go back home"
                      : "Internal Serialization Error\nTap to return to profile",
                  style: notInLibraryFont,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Center(
              child: LoadingIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ReaderFrame extends StatefulWidget {
  @override
  _ReaderFrameState createState() => _ReaderFrameState();
}

class _ReaderFrameState extends State<ReaderFrame> {
  bool _showControls = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            plain(),
            ViewerGateWay(
              initialPage: Provider.of<ReaderProvider>(context, listen: false)
                  .initialPageindex,
            ),
            header(),
            footer(),
          ],
        ),
      ),
    );
  }

  Widget plain() => GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Container(),
      );

  Widget header() {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return AnimatedPositioned(
        duration: Duration(
          milliseconds: 150,
        ),
        top: _showControls ? 0 : -120.h,
        curve: Curves.easeIn,
        height: 120.h,
        width: MediaQuery.of(context).size.width,
        child: Container(
          alignment: Alignment.topCenter,
          color: Colors.black,
          height: 120.h,
          child: Column(
            children: <Widget>[
              Container(
                height: 55.h,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 50.w,
                        child: FlatButton(
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                            size: 30.sp,
                          ),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 2.w,
                height: 3.h,
                color: Colors.grey[900],
              ),
              Container(
                height: 60,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                  fontSize: 18.sp,
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
                  ],
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
      return AnimatedPositioned(
        duration: Duration(milliseconds: 150),
        curve: Curves.ease,
        bottom: _showControls ? 0 : -60.h,
        child: Container(
          height: 60.h,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                  ),
                ),
                Spacer(),
                provider.pageDisplayNumber != null
                    ? Text(
                        "${provider.pageDisplayNumber}/${provider.pageDisplayCount}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          fontFamily: 'Lato',
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                Spacer(),
                IconButton(
                  onPressed: () async {},
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
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
