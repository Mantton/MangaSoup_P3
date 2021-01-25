import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class MangaReader extends StatefulWidget {
  final int page;

  const MangaReader({Key key, this.page}) : super(key: key);

  @override
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  @override
  void initState() {
    // _controller.addListener(loadChapter);
    _externalController = PageController(initialPage: widget.page - 1);
    _internalController = PreloadPageController();
    _internalController.addListener(loadChapter);
    super.initState();
  }

  loadChapter() async {
    double maxScroll = _internalController.position.maxScrollExtent;
    // double minScroll = _internalController.position.minScrollExtent;
    double currentScroll = _internalController.position.pixels;
    double delta = _internalController.position.maxScrollExtent * .30;

    if (maxScroll - currentScroll < delta &&
        Provider.of<ReaderProvider>(context, listen: false).loadingMore ==
            false &&
        !Provider.of<ReaderProvider>(context, listen: false).custom) {
      await Provider.of<ReaderProvider>(context, listen: false).addChapter(
        context: context,
      );
    }
  }

  PageController _externalController;
  PreloadPageController _internalController;
  ScrollController _activeScrollController;
  Drag _drag;

  @override
  void dispose() {
    _externalController.dispose();
    _internalController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_internalController.hasClients &&
        _internalController.position.context.storageContext != null) {
      final RenderBox renderBox = _internalController
          .position.context.storageContext
          .findRenderObject();
      if (renderBox.paintBounds
          .shift(renderBox.localToGlobal(Offset.zero))
          .contains(details.globalPosition)) {
        _activeScrollController = _internalController;
        _drag = _activeScrollController.position.drag(details, _disposeDrag);
        return;
      }
    }
    _activeScrollController = _externalController;
    _drag = _externalController.position.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var scrollDirection = _activeScrollController.position.userScrollDirection;

    if (_activeScrollController == _internalController &&
        ((scrollDirection == ScrollDirection.reverse) &&
                _activeScrollController.offset.roundToDouble() >=
                    _activeScrollController.position.maxScrollExtent
                        .roundToDouble() ||
            (scrollDirection == ScrollDirection.forward) &&
                _activeScrollController.offset < 0)) {
      _activeScrollController = _externalController;
      _drag?.cancel();
      _drag = _externalController.position.drag(
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

  int chapterHolder = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          VerticalDragGestureRecognizer: provider.scrollDirectionMode != 0
              ? GestureRecognizerFactoryWithHandlers<
                  VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                  (VerticalDragGestureRecognizer instance) {
                    instance
                      ..onStart = _handleDragStart
                      ..onUpdate = _handleDragUpdate
                      ..onEnd = _handleDragEnd
                      ..onCancel = _handleDragCancel;
                  },
                )
              : GestureRecognizerFactoryWithHandlers<
                  VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                  (VerticalDragGestureRecognizer instance) {},
                ),
          HorizontalDragGestureRecognizer: provider.scrollDirectionMode == 0
              ? GestureRecognizerFactoryWithHandlers<
                  HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                  (HorizontalDragGestureRecognizer instance) {
                    instance
                      ..onStart = _handleDragStart
                      ..onUpdate = _handleDragUpdate
                      ..onEnd = _handleDragEnd
                      ..onCancel = _handleDragCancel;
                  },
                )
              : GestureRecognizerFactoryWithHandlers<
                  HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                  (HorizontalDragGestureRecognizer instance) {},
                ),
        },
        behavior: HitTestBehavior.opaque,
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _externalController,
          scrollDirection:
              provider.orientationMode == 0 ? Axis.horizontal : Axis.vertical,
          reverse: provider.scrollDirectionMode == 0 ? true : false,
          onPageChanged: (p) {
            provider.setPage(0, false);
            provider.setImageChapter(p);
            showMessage(
              "${p > chapterHolder
                  ? "Next Chapter"
                  : "Previous Chapter"} \n ${provider.currentChapter.name}",
              Icons.menu_book_rounded,
              Duration(seconds: 1),
            );
            setState(() {
              chapterHolder = p;
            });
          },
          children: provider.loadedChapters
              .map(
                (chapter) => ChapterViewer(
                  chapter: chapter,
                  chapterHolder: chapterHolder,
                  controller: chapterHolder ==
                      provider.loadedChapters.indexOf(chapter)
                      ? _internalController
                      : null,
                  provider: provider,
                ),
              )
              .toList(),
        ),
      );
    });
  }

}

class ChapterViewer extends StatefulWidget {
  final ImageChapter chapter;
  final provider;
  final PreloadPageController controller;
  final int chapterHolder;

  const ChapterViewer(
      {Key key,
      this.chapter,
      this.provider,
      this.controller,
      this.chapterHolder})
      : super(key: key);

  @override
  _ChapterViewerState createState() => _ChapterViewerState();
}

class _ChapterViewerState extends State<ChapterViewer>
    with AutomaticKeepAliveClientMixin {
  List<Widget> buildChapterImages({ImageChapter imageChapter}) {
    List<Widget> chapter = List();
    List<Widget> images = imageChapter.images
        .map(
          (image) => Center(
            child: Container(
              padding: EdgeInsets.all(
                Provider.of<ReaderProvider>(context).paddingMode == 0
                    ? 10
                    : 0,
              ),
              width: MediaQuery.of(context).size.width,
              child: OldReaderImage(
                link: image,
                referer: imageChapter.referer,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        )
        .toList();

    chapter.addAll(images);
    // chapter.add(TransitionPage());

    return chapter;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: PreloadPageView(
        physics: NeverScrollableScrollPhysics(),
        pageSnapping: widget.provider.snappingMode == 0 ? true : false,
        preloadPagesCount: 2,
        scrollDirection: widget.provider.orientationMode == 0
            ? Axis.horizontal
            : Axis.vertical,
        reverse: widget.provider.scrollDirectionMode == 0 ? true : false,
        controller: widget.chapterHolder ==
                widget.provider.loadedChapters.indexOf(widget.chapter)
            ? widget.controller
            : null,
        onPageChanged: (p) {
          widget.provider.setPage(p, false);
        },
        children: buildChapterImages(
          imageChapter: widget.chapter,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
