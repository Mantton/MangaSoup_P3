import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/double_paged_reader/doubled_page_logic.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class DoublePagedAdapter extends StatefulWidget {
  final int initialPage;

  const DoublePagedAdapter({Key key, this.initialPage}) : super(key: key);

  @override
  _DoublePagedAdapterState createState() => _DoublePagedAdapterState();
}

class _DoublePagedAdapterState extends State<DoublePagedAdapter>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    print(widget.initialPage);
    super.initState();
  }

  PreloadPageController _controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        _controller = PreloadPageController(
            initialPage: doublePagedGetInitial(widget.initialPage),
            viewportFraction: 1);
        Map<String, dynamic> t = createDouble(
            provider.widgetPageList, settings.readerScrollDirection == 1);
        return PreloadPageView(
          scrollDirection:
              settings.readerOrientation == 1 ? Axis.horizontal : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: _controller,
          reverse: settings.readerScrollDirection == 1 ? true : false,
          onPageChanged: (i) {
            int p = t['pages'][i] - 1;
            print(p);
            provider.pageChanged(p);
          },
          preloadPagesCount: 4,
          children: t['widgets'],
        );
      });
    });
  }

  @override
  bool get wantKeepAlive => false;
}
