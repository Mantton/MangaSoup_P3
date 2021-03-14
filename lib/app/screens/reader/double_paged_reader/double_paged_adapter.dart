import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/double_paged_reader/doubled_page_logic.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class DoublePagedAdapter extends StatelessWidget {
  final PreloadPageController controller;

  const DoublePagedAdapter({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Consumer<PreferenceProvider>(builder: (context, settings, _) {
        Map<String, dynamic> t = createDouble(
            provider.widgetPageList, settings.readerScrollDirection == 1);
        return PreloadPageView.builder(
          scrollDirection:
              settings.readerOrientation == 1 ? Axis.horizontal : Axis.vertical,
          pageSnapping: settings.readerPageSnapping,
          controller: controller,
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
}
