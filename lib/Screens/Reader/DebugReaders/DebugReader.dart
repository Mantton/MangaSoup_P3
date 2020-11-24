import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class DebugReader extends StatefulWidget {
  final List<Chapter> chapters;
  final bool downloaded;
  final Chapter selectedChapter;
  final String selector;
  final ChapterDownloadObject cdo;

  const DebugReader({
    Key key,
    this.chapters,
    this.downloaded = false,
    this.selectedChapter,
    @required this.selector,
    this.cdo,
  }) : super(key: key);

  @override
  _DebugReaderState createState() => _DebugReaderState();
}

class _DebugReaderState extends State<DebugReader> {
  ApiManager _manager = ApiManager();

  Future<bool> init(Chapter chapter) async {
    if (widget.downloaded) {
      ImageChapter c = ImageChapter(
        images: widget.cdo.images,
        source: widget.cdo.highlight.source,
        referer: widget.cdo.highlight.imageReferer,
        count: widget.cdo.images.length,
      );
      loadedChapters.add(c);
    } else
      loadedChapters
          .add(await _manager.getImages(widget.selector, chapter.link));
    return true;
  }

  Future<ImageChapter> getImages(Chapter chapter) async {
    return _manager.getImages(widget.selector, chapter.link);
  }

  Future<bool> initializer;
  List<ImageChapter> loadedChapters = List();
  bool vertical = true;
  int readerMode = 0;

  @override
  void initState() {
    super.initState();
    initializer = init(widget.selectedChapter);
    _pageController = PageController();
    _listScrollController = ScrollController();
  }

  PageController _pageController;
  ScrollController _listScrollController;
  ScrollController _activeScrollController;
  Drag _drag;

  @override
  void dispose() {
    _pageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_listScrollController.hasClients &&
        _listScrollController.position.context.storageContext != null) {
      final RenderBox renderBox = _listScrollController
          .position.context.storageContext
          .findRenderObject();
      if (renderBox.paintBounds
          .shift(renderBox.localToGlobal(Offset.zero))
          .contains(details.globalPosition)) {
        _activeScrollController = _listScrollController;
        _drag = _activeScrollController.position.drag(details, _disposeDrag);
        return;
      }
    }
    _activeScrollController = _pageController;
    _drag = _pageController.position.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var scrollDirection = _activeScrollController.position.userScrollDirection;

    if (_activeScrollController == _listScrollController &&
        ((scrollDirection == ScrollDirection.reverse) &&
                _activeScrollController.offset.roundToDouble() >=
                    _activeScrollController.position.maxScrollExtent
                        .roundToDouble() ||
            (scrollDirection == ScrollDirection.forward) &&
                _activeScrollController.offset < 0)) {
      _activeScrollController = _pageController;
      _drag?.cancel();
      _drag = _pageController.position.drag(
          DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition),
          _disposeDrag);
    }
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  void _handleDragCancel() {
    _drag?.cancel();
  }

  void _disposeDrag() {
    _drag = null;
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Test Reader : $_page"),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_left_rounded),
            onPressed: () {
              setState(() {
                vertical = !vertical;
                print(vertical);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.phone_android),
            onPressed: () {
              setState(() {
                if (readerMode == 1) {
                  readerMode = 0;

                  print("PageView");
                } else
                  readerMode = 1;
              });
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: initializer,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Internal Error"),
              );
            }
            if (snapshot.hasData)
              return home();
            else {
              return Center(child: Text("Critical Error,"));
            }
          }),
    );
  }

  Widget home() {
    return Container(child: readerMode == 1 ? testOne() : fromGit());
  }

  Widget testOne() {
    return ListView(
      scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
      shrinkWrap: true,
      children: loadedChapters
          .map(
            (chapter) =>
            ListView(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
              shrinkWrap: true,
              children: chapter.images
                  .map(
                    (image) =>
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              // padding: EdgeInsets.all(10),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              child: ReaderImage(
                                link: image,
                                referer: chapter.referer,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              )
                  .toList(),
            ),
      )
          .toList(),
    );
  }

  Widget fromGit() {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
                (VerticalDragGestureRecognizer instance) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel;
            }),
      },
      behavior: HitTestBehavior.opaque,
      child: PageView(
        scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        children: loadedChapters
            .map(
              (chapter) =>
              PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                // preloadPagesCount: 2,
                scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
                onPageChanged: (p) {
                  setState(() {
                    _page = p;
                  });
                },
                children: chapter.images
                    .map(
                      (image) =>
                      Center(
                        child: SingleChildScrollView(
                          controller: _listScrollController,
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: ReaderImage(
                                  link: image,
                                  referer: chapter.referer,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                )
                    .toList(),
              ),
        )
            .toList(),
      ),
    );
  }
}
