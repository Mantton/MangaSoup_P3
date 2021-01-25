import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';

import '../Globals.dart';

class OldReaderImage extends StatefulWidget {
  final String link;
  final String referer;
  final BoxFit fit;

  const OldReaderImage({Key key, this.link, this.referer, this.fit})
      : super(key: key);

  @override
  _OldReaderImageState createState() => _OldReaderImageState();
}

class _OldReaderImageState extends State<OldReaderImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (!widget.link.toLowerCase().contains("mangasoup"))
          ? ReaderImage(
              url: widget.link,
              referer: widget.referer,
              fit: widget.fit,
            )
          : Image.file(
              File(widget.link),
            ),
    );
  }
}

class ReaderImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final String referer;
  final Size imageSize;
  final bool mangaMode;

  const ReaderImage(
      {Key key,
      this.url,
      this.fit,
      this.referer,
      this.imageSize,
      this.mangaMode = true})
      : super(key: key);

  @override
  _ReaderImageState createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url,
      progressIndicatorBuilder: (_, url, var progress) =>
          progress.progress != null
              ? Container(
                  height: (widget.mangaMode)
                      ? MediaQuery.of(context).size.height
                      : widget.imageSize.height,
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
                    height: (widget.mangaMode)
                        ? MediaQuery.of(context).size.height
                        : widget.imageSize.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text("Loading..."),
                    ),
                  ),
                ),
      httpHeaders: {"referer": widget.referer ?? imageHeaders(widget.url)},
      errorWidget: (context, url, error) => Center(
        child: Container(
          height: (widget.mangaMode)
              ? MediaQuery.of(context).size.height
              : widget.imageSize.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text("$error"),
          ),
        ),
      ),
      fit: widget.fit,
      fadeInDuration: Duration(microseconds: 500),
      fadeInCurve: Curves.easeIn,
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

class _VioletImageState extends State<VioletImage> with AutomaticKeepAliveClientMixin {
  Future<Size> testing;

  @override
  void initState() {
    super.initState();
    testing = _calculateNetworkImageDimension(widget.url, widget.referrer);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: testing,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ReaderImage(
            url: widget.url,
            referer: widget.referrer,
            fit: widget.fit,
            imageSize: snapshot.data,
          );
        }
        if (snapshot.hasError) {
          return Container(
            height: 300,
            color: Colors.red,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: LoadingIndicator(),
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
    Image image = new Image(
      image: CachedNetworkImageProvider(
        uri,
        headers: {"referer": ref},
      ),
    );
    Completer<Size> completer = Completer();
    try {
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
            var myImage = image.image;
            Size size = Size(
              myImage.width.toDouble(),
              myImage.height.toDouble(),
            );
            completer.complete(size);
          },
        ),
      );
    } catch (err) {
      print("ERROR : $err");
      completer.complete(MediaQuery.of(context).size);
    }

    return completer.future;
  }

  @override
  bool get wantKeepAlive => true;
}
