import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_page_adapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_adapter.dart';
import 'package:provider/provider.dart';
class ViewerGateWay extends StatefulWidget {
  final int initialPage;

  const ViewerGateWay({Key key, this.initialPage}) : super(key: key);
  @override
  _ViewerGateWayState createState() => _ViewerGateWayState();
}

class _ViewerGateWayState extends State<ViewerGateWay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return Container(
        // child: WebToonPageAdapter(),
        child: provider.readerMode == 1
            ? PagedViewAdapter(
                initialPage: widget.initialPage,
              )
            : WebToonPageAdapter(
                initialPage: widget.initialPage,
              ),
      );
    });
  }
}
