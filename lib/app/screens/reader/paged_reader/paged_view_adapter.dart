import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class PagedViewAdapter extends StatefulWidget {
  @override
  _PagedViewAdapterState createState() => _PagedViewAdapterState();
}

class _PagedViewAdapterState extends State<PagedViewAdapter> {
  @override
  void initState() {
    super.initState();
    _controller = PreloadPageController(
        initialPage: Provider.of<ReaderProvider>(context, listen: false)
            .initialPageIndex,
        viewportFraction: 1);
  }

  PreloadPageController _controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        return PreloadPageView.builder(
          scrollDirection:
              settings.readerOrientation == 1 ? Axis.horizontal : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: _controller,
          reverse: settings.readerScrollDirection == 1 ? true : false,
          onPageChanged: provider.pageChanged,
          preloadPagesCount: 4,
          itemBuilder: (_, index) => provider.widgetPageList[index],
          itemCount: provider.widgetPageList.length,
        );
      });
    });
  }
}
