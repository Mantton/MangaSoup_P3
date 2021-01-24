import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:provider/provider.dart';

class WebtoonReader extends StatefulWidget {
  final int initialPage;

  const WebtoonReader({Key key, this.initialPage}) : super(key: key);

  @override
  _WebtoonReaderState createState() => _WebtoonReaderState();
}

class _WebtoonReaderState extends State<WebtoonReader> {
  PageController _externalController;
  ScrollController _internalController;
  int chapterHolder = 0;
  int pageHolder = 1;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _externalController = PageController();
    _internalController.addListener(internalListener);
    _externalController.addListener(externalListener);
  }

  ScrollController _activeScrollController;
  Drag _drag;

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

  internalListener() async {
    int pageCount =
        Provider.of<ReaderProvider>(context, listen: false).chapterLength;
    double extent = _internalController.position.maxScrollExtent;
    double extentPerPage = extent / pageCount;
    double currentExtent = _internalController.position.pixels;
    int holder = (currentExtent / extentPerPage).round();

    if (holder != pageHolder) {
      if (holder > pageCount)
        pageHolder = pageCount;
      else
        pageHolder = holder;
      Provider.of<ReaderProvider>(context, listen: false)
          .setPage(pageHolder, true);
      print(
        "Current Extent: $currentExtent \n "
        "Extent Per Page: $extentPerPage \n "
        "Max Extent: $extent\n"
        "Page: $pageHolder \n\n\n",
      );
    }

    double maxScroll = _internalController.position.maxScrollExtent;
    double minScroll = _internalController.position.minScrollExtent;
    double currentScroll = _internalController.position.pixels;
    double delta = maxScroll * .20;

    if (maxScroll - currentScroll < delta &&
        Provider.of<ReaderProvider>(context, listen: false).loadingMore ==
            false &&
        !Provider.of<ReaderProvider>(context, listen: false).custom) {
      await Provider.of<ReaderProvider>(context, listen: false).addChapter(
          context: context,
      );
    }
  }

  externalListener() {}

  @override
  void dispose() {
    _externalController.dispose();
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          },
        ),
      },
      behavior: HitTestBehavior.opaque,
      child: Consumer<ReaderProvider>(builder: (context, provider, _) {
        return Container(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _externalController,
            scrollDirection: Axis.vertical,
            onPageChanged: (p) {
              // provider.setPage(0);
              provider.setImageChapter(p);
              showMessage(
                "${p > chapterHolder ? "Next Chapter" : "Previous Chapter"} \n ${provider.currentChapter.name}",
                Icons.menu_book_rounded,
                Duration(seconds: 1),
              );
              setState(() {
                chapterHolder = p;
              });
            },
            children: Provider.of<ReaderProvider>(context)
                .loadedChapters
                .map(
                  (chapter) => ChapterListView(
                    chapter: chapter,
                    internalController: chapterHolder ==
                            provider.loadedChapters.indexOf(chapter)
                        ? _internalController
                        : null,
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }
}

class ChapterListView extends StatefulWidget {
  final ImageChapter chapter;
  final ScrollController internalController;

  const ChapterListView({Key key, this.chapter, this.internalController})
      : super(key: key);

  @override
  _ChapterListViewState createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> {
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return ListView(
      controller: widget.internalController,
      physics: NeverScrollableScrollPhysics(),
      cacheExtent: MediaQuery.of(context).size.height,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: widget.chapter.images
          .map(
            (image) => Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: ReaderImage(
                  link: image,
                  referer: widget.chapter.referer,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
