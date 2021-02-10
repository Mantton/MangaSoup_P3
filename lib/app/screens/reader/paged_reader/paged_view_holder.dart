import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';

class PagedViewHolder extends StatefulWidget {
  final ReaderPage page;

  const PagedViewHolder({Key key, this.page}) : super(key: key);
  @override
  _PagedViewHolderState createState() => _PagedViewHolderState();
}

class _PagedViewHolderState extends State<PagedViewHolder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PagedImage(
        page: widget.page,
      ),
    );
  }
}

class PagedImage extends StatelessWidget {
  final ReaderPage page;
  const PagedImage({
    Key key,
    @required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReaderImage(
      referer: page.referer,
      url: page.imgUrl,
      // fit: BoxFit.fitWidth,
    );
  }
}
