import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_holder.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PageViewAdapter extends StatefulWidget {
  final List<ReaderPage> pages;

  const PageViewAdapter({Key key, this.pages}) : super(key: key);
  @override
  _PageViewAdapterState createState() => _PageViewAdapterState();
}

class _PageViewAdapterState extends State<PageViewAdapter> {
  @override
  Widget build(BuildContext context) {
    return PreloadPageView.builder(
        itemCount: widget.pages.length,
        preloadPagesCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return PagedViewHolder(
            page: widget.pages[index],
          );
        });
  }
}
