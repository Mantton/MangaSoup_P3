import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../Globals.dart';


class SoupImage extends StatelessWidget {
  final String url;
  final String referer;
  final BoxFit fit;
  final String sourceId;
  Future<String> cookies;

  SoupImage(
      {Key key, this.url, this.referer, this.sourceId, this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCookies(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          if (snapshot.hasData) {
            return mainBody(snapshot.data);
          } else {
            return CupertinoActivityIndicator();
          }
        });
  }

  Widget mainBody(String cookies) {
    return Container(
      child: CachedNetworkImage(
        memCacheHeight: 800,
        memCacheWidth: 600,
        imageUrl: (!url.contains("https:https:"))
            ? url
            : url.replaceFirst("https:", ""),
        httpHeaders: referer != null
            ? {
                "User-Agent": 'MangaSoup/0.0.3',
                "Cookie": cookies,
                "referer": referer ?? imageHeaders(url)
              }
            : null,
        placeholder: (context, url) => Center(
          child: CupertinoActivityIndicator(
            radius: 10,
          ),
        ),
        fadeInDuration: Duration(
          microseconds: 100,
        ),
        errorWidget: (context, url, error) {
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

  Future<String> getCookies() async {
    Map info = await prepareAdditionalInfo(sourceId);

    Map cookies = info['cookies'];

    if (cookies == null) return "";
    return stringifyCookies(cookies);
  }

  String stringifyCookies(Map cookies) =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
}

class GalleryViewer extends StatefulWidget {
  final List images;
  final int initialIndex;

  const GalleryViewer({Key key, this.images, this.initialIndex})
      : super(key: key);

  @override
  _GalleryViewerState createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

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

          pageController: _controller,
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
