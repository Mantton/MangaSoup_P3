import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_view_holder.dart';
import 'package:preload_page_view/preload_page_view.dart';

class WebtoonViewAdapter extends StatefulWidget {
  final List<ReaderPage> pages;

  const WebtoonViewAdapter({Key key, this.pages}) : super(key: key);

  @override
  _WebtoonViewAdapterState createState() => _WebtoonViewAdapterState();
}

class _WebtoonViewAdapterState extends State<WebtoonViewAdapter> {
  PageController _externalController;
  ScrollController _internalController;
  int chapterHolder = 0;
  int pageHolder = 1;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _externalController = PageController();
  }

  @override
  void dispose() {
    _externalController.dispose();
    _internalController.dispose();
    super.dispose();
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
      child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: _externalController,
          pageSnapping: false,
          onPageChanged: (page) => print(page),
          itemCount: widget.pages.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return WebToonPageHolder(
              page: widget.pages[index],
              internalController: (_externalController.page.toInt() == index)
                  ? _internalController
                  : null,
            );
          }),
    );
  }
}


class TesterWeebToon extends StatefulWidget {
  final List<ReaderPage> page;

  const TesterWeebToon({Key key, this.page}) : super(key: key);

  @override
  _TesterWeebToonState createState() => _TesterWeebToonState();
}

class _TesterWeebToonState extends State<TesterWeebToon> {


  @override
  Widget build(BuildContext context) {
    return PreloadPageView.builder(scrollDirection: Axis.vertical,itemBuilder: (_, int index)=>VioletImage(
      url: widget.page[index].imgUrl,
      referrer: widget.page[index].referer,
      fit: BoxFit.fitWidth,
    ),);
  }
}
