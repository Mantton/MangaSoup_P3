import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_page_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_adapter.dart';
import 'package:provider/provider.dart';

import '../reader_provider.dart';

class ViewerGateWay extends StatefulWidget {
  @override
  _ViewerGateWayState createState() => _ViewerGateWayState();
}

class _ViewerGateWayState extends State<ViewerGateWay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Container(
        // child: WebToonPageAdapter(),
        child:PagedViewAdapter(),
      );
    });
  }
}
