import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/double_paged_reader/double_paged_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_page_adapter.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ViewerGateWay extends StatelessWidget {
  final PreloadPageController pagedController;
  final PreloadPageController doublePagedController;
  final ItemScrollController webToonController;

  const ViewerGateWay(
      {Key key,
      @required this.pagedController,
      @required this.doublePagedController,
      @required this.webToonController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return provider.readerMode == 1
          ? !provider.readerDoublePagedMode
              ? PagedViewAdapter(
                  controller: pagedController,
                )
              : DoublePagedAdapter(
                  controller: doublePagedController,
                )
          : WebToonPageAdapter(
              controller: webToonController,
            );
    });
  }
}
