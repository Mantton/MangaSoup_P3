import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PagedViewHolder extends StatefulWidget {
  final ReaderPage page;

  const PagedViewHolder({Key key, this.page}) : super(key: key);
  @override
  _PagedViewHolderState createState() => _PagedViewHolderState();
}

class _PagedViewHolderState extends State<PagedViewHolder> {
  @override
  Widget build(BuildContext context) {
    return TestImage(
      page: widget.page,
    );
  }
}

class TestImage extends StatelessWidget {
  final ReaderPage page;
  const TestImage({
    Key key,
    @required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      maxScale: 2.0,
      minScale: 0.3,
      initialScale: PhotoViewComputedScale.contained,
      gaplessPlayback: true,
      imageProvider: CachedNetworkImageProvider(page.imgUrl),
      loadingBuilder: (_, event) {
        return event != null
            ? Container(
                child: Center(
                  child: Text(
                    ((event.cumulativeBytesLoaded / event.expectedTotalBytes) *
                            100)
                        .toInt().toString(),
                  ),
                ),
              )
            : Center(
                child: Text(
                  "Loading",style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Lato",
                ),
                ),
              );
      },
    );
  }
}
