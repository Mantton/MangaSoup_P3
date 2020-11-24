import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Globals.dart';

class ReaderImage extends StatefulWidget {
  final String link;
  final String referer;
  final BoxFit fit;

  const ReaderImage({Key key, this.link, this.referer, this.fit})
      : super(key: key);

  @override
  _ReaderImageState createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (!widget.link.toLowerCase().contains("mangasoup"))
          ? cImage(
              url: widget.link,
              referer: widget.referer,
              fit: widget.fit,
              context: context,
            )
          : Image.file(
              File(widget.link),
            ),
    );
  }
}

Widget cImage({String url, BoxFit fit, String referer, BuildContext context}) {
  return CachedNetworkImage(

    imageUrl: url,
    progressIndicatorBuilder: (_, url, var progress) =>
    progress.progress != null
        ? Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
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
        : Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Center(
        child: Text("Loading..."),
      ),
    ),
    httpHeaders: {"referer": referer ?? imageHeaders(url)},
    errorWidget: (context, url, error) => Icon(
      Icons.error,
      color: Colors.purple,
    ),
    fit: fit,
  );
}
/*
* Image.network(
              widget.link,
              headers: {"referer": "${widget.referer}"},
              errorBuilder: (_, var error, var stacktrace) => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.error_outline,
                    color: Colors.purple,
                  ),
                )),
              ),
              loadingBuilder: (_, Widget child, ImageChunkEvent progress) {
                if (progress == null) return child;
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes
                              : null,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple),
                          strokeWidth: 5,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Loading...")
                      ],
                    ),
                  ),
                );
              },
            )
* */
