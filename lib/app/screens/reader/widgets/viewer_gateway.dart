import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/double_paged_reader/double_paged_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_page_adapter.dart';
import 'package:provider/provider.dart';

class ViewerGateWay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return provider.readerMode == 1
          ? !provider.readerDoublePagedMode
              ? PagedViewAdapter()
              : DoublePagedAdapter()
          : WebToonPageAdapter();
    });
  }
}
