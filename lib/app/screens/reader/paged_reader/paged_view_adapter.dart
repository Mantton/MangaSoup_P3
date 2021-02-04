import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class PagedViewAdapter extends StatefulWidget {
  @override
  _PagedViewAdapterState createState() => _PagedViewAdapterState();
}

class _PagedViewAdapterState extends State<PagedViewAdapter>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return PreloadPageView(
        // scrollDirection: Axis.vertical,
        reverse: true,
        onPageChanged: provider.pageChanged,
        preloadPagesCount: 3,
        children: provider.widgetPageList,
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
