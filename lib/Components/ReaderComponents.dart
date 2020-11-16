import 'dart:io';

import 'package:flutter/material.dart';

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
          ? Image.network(
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
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    strokeWidth: 5,
                  ),
                );
              },
            )
          : Image.file(
              File(widget.link),
            ),
    );
  }
}
