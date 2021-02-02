import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';

class WebToonPageHolder extends StatelessWidget {
  final ScrollController internalController;
  final ReaderPage page;

  const WebToonPageHolder({Key key, this.internalController, this.page})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
        controller: internalController,
        physics: NeverScrollableScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,

        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: VioletImage(
                url: page.imgUrl,
                referrer: page.referer,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ]);
  }
}
