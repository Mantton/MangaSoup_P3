import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../Globals.dart';

class SoupImage extends StatelessWidget {
  final String url;
  final String referer;
  final BoxFit fit;

  const SoupImage({Key key, this.url, this.referer, this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(
        memCacheHeight: 800,
        memCacheWidth: 600,
        imageUrl: (!url.contains("https:https:"))
            ? url
            : url.replaceFirst("https:", ""),
        httpHeaders:
            referer != null ? {"referer": referer ?? imageHeaders(url)} : null,
        placeholder: (context, url) => Center(
          child: CupertinoActivityIndicator(
            radius: 10,
          ),
        ),
        fadeInDuration: Duration(
          microseconds: 100,
        ),
        errorWidget: (context, url, error) {
          print(url);
          print(error);
          CachedNetworkImage.evictFromCache(url);
          return Icon(
            Icons.error,
            color: Colors.purple,
          );
        },
        fit: fit,
      ),
    );
  }
}

class GalleryViewer extends StatelessWidget {
  final List images;

  const GalleryViewer({Key key, this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        centerTitle: true,
        backgroundColor: Colors.black45,
      ),
      body: Container(
        child: PhotoViewGallery.builder(
          // scrollPhysics:  BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(images[index]),
              initialScale: PhotoViewComputedScale.covered * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: "MangaSoup"),
            );
          },
          itemCount: images.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 40.0,
              height: 40.0,
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
