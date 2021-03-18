import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';


class PagedViewAdapter extends StatelessWidget {
  final PreloadPageController controller;

  const PagedViewAdapter({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        return PreloadPageView.builder(
          scrollDirection:
              settings.readerOrientation == 1 ? Axis.horizontal : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: controller,
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
