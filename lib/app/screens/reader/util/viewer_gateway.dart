import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class ViewerGateway extends StatefulWidget {
  @override
  _ViewerGatewayState createState() => _ViewerGatewayState();
}

class _ViewerGatewayState extends State<ViewerGateway> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _){
      return PreloadPageView(
        onPageChanged: provider.pageChanged,
        preloadPagesCount: 3,
        children: provider.widgetPageList,
      );
    });
  }
}
