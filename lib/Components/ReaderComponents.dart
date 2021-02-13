import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';

import '../Globals.dart';

class ReaderImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final String referer;
  final Size imageSize;

  const ReaderImage(
      {Key key,
      this.url,
      this.fit = BoxFit.fitWidth,
      this.referer,
      this.imageSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // double proportionalHeight = MediaQuery.of(context).size.width/imageSize.aspectRatio;

    return Center(
      child: InteractiveViewer(
        maxScale: 3.5,
        minScale: .5,
        panEnabled: false,
        child: CachedNetworkImage(
          imageUrl: url,
          progressIndicatorBuilder: (_, url, var progress) =>
              progress.progress != null
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text(
                          "${(progress.progress * 100).toInt()}%",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text("Loading..."),
                        ),
                      ),
                    ),
          httpHeaders: {"referer": referer ?? imageHeaders(url)},
          errorWidget: (context, url, error) => Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Icon(
                Icons.error_outline,
                color: Colors.purple,
              )),
            ),
          ),
          fit: fit,
          fadeInDuration: Duration(microseconds: 500),
          fadeInCurve: Curves.easeIn,
        ),
      ),
    );
  }
}

class VioletImage extends StatefulWidget {
  final String url;
  final String referrer;
  final BoxFit fit;

  const VioletImage({Key key, this.url, this.referrer, this.fit})
      : super(key: key);

  @override
  _VioletImageState createState() => _VioletImageState();
}

class _VioletImageState extends State<VioletImage>
    with AutomaticKeepAliveClientMixin {
  Future<Size> _getDimensions;

  @override
  void initState() {
    super.initState();
    _getDimensions = hello();
  }

  Future<Size> hello() async {
    return await _calculateNetworkImageDimension(widget.url, widget.referrer);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _getDimensions,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: ReaderImage(
              url: widget.url,
              referer: widget.referrer,
              fit: widget.fit,
              imageSize: snapshot.data,
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            child: Text("${snapshot.error}"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(child: LoadingIndicator()),
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "You should not be seeing this.",
              ),
            ),
          );
        }
      },
    );
  }

  Future<Size> _calculateNetworkImageDimension(String uri, String ref) async {
    Image image = Image(
      image: NetworkImage(
        uri,
        headers: {"referer": ref},
      ),
    );
    Completer<Size> completer = Completer();

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool _) {
          var myImage = image.image;
          Size size = Size(
            myImage.width.toDouble(),
            myImage.height.toDouble(),
          );
          completer.complete(size);
        },
      ),
    );

    return completer.future;
  }

  @override
  bool get wantKeepAlive => false;
}
