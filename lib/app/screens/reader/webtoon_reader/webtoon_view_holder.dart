import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';


class WebToonViewHolder extends StatefulWidget {
  final ReaderPage page;

  const WebToonViewHolder({Key key, this.page}) : super(key: key);
  @override
  _WebToonViewHolderState createState() => _WebToonViewHolderState();
}

class _WebToonViewHolderState extends State<WebToonViewHolder> {
  @override
  Widget build(BuildContext context) {
    return VioletImage(
      url: widget.page.imgUrl,
      referrer: widget.page.referer,
    );
  }
}
