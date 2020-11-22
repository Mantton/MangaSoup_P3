import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:preload_page_view/preload_page_view.dart';

class VerticalReader extends StatefulWidget {
  @override
  _VerticalReaderState createState() => _VerticalReaderState();
}

class _VerticalReaderState extends State<VerticalReader> {
  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController();
    _listScrollController = ScrollController();
  }

  PreloadPageController _pageController;
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

  int _page = 0;
  List<ImageChapter> loadedChapters = List();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                    VerticalDragGestureRecognizer>(
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
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            children: loadedChapters
                .map(
                  (chapter) => PreloadPageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    preloadPagesCount: 2,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (p) {
                      setState(() {
                        _page = p;
                      });
                    },
                    children: chapter.images
                        .map(
                          (image) => Center(
                            child: SingleChildScrollView(
                              controller: _listScrollController,
                              physics: NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
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
        ),
      ],
    );
  }
}

/*
* todo
* Paginate on end or show show next indicator
*
*
* */
