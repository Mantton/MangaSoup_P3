import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class PagedViewAdapter extends StatefulWidget {
  final int initialPage;

  const PagedViewAdapter({Key key, this.initialPage}) : super(key: key);
  @override
  _PagedViewAdapterState createState() => _PagedViewAdapterState();
}

class _PagedViewAdapterState extends State<PagedViewAdapter>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    print(widget.initialPage);
    _controller = PreloadPageController(initialPage: widget.initialPage);
    super.initState();
  }

  PreloadPageController _controller;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        return PreloadPageView(
          scrollDirection: settings.readerOrientation == 1
              ? Axis.horizontal
              : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: _controller,
          reverse: settings.readerScrollDirection == 1 ? true : false,
          onPageChanged: provider.pageChanged,
          preloadPagesCount: 4,
          children: provider.widgetPageList,
        );
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
