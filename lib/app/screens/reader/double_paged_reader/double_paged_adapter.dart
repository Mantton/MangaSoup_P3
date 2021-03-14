import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/double_paged_reader/doubled_page_logic.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class DoublePagedAdapter extends StatefulWidget {

  @override
  _DoublePagedAdapterState createState() => _DoublePagedAdapterState();
}

class _DoublePagedAdapterState extends State<DoublePagedAdapter>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  PreloadPageController _controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        _controller = PreloadPageController(
          initialPage: doublePagedGetInitial(provider.initialPageIndex),
          viewportFraction: 1,
        );
        Map<String, dynamic> t = createDouble(
            provider.widgetPageList, settings.readerScrollDirection == 1);
        return PreloadPageView.builder(
          scrollDirection:
              settings.readerOrientation == 1 ? Axis.horizontal : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: _controller,
          reverse: settings.readerScrollDirection == 1 ? true : false,
          onPageChanged: (i) {
            int p = t['pages'][i] - 1;
            provider.pageChanged(p);
          },
          preloadPagesCount: 4,
          itemBuilder: (_, index) => t['widgets'][index],
          itemCount: t['widgets'].length,
        );
      });
    });
  }

  @override
  bool get wantKeepAlive => false;
}
