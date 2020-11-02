import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SoupImage extends StatelessWidget {
  final String url;

  const SoupImage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => Center(
          child: CupertinoActivityIndicator(
            radius: 10.w,
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          color: Colors.purple,
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}

class GalleryViewer extends StatefulWidget {
  final List images;

  const GalleryViewer({Key key, this.images}) : super(key: key);

  @override
  _GalleryViewerState createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoViewGallery.builder(
          // scrollPhysics:  BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(widget.images[index]),
              initialScale: PhotoViewComputedScale.covered * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: "MangaSoup"),
            );
          },
          itemCount: widget.images.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 40.0.w,
              height: 40.0.h,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
