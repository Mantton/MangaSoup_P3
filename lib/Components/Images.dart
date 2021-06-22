import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../Globals.dart';

class SoupImage extends StatefulWidget {
  final String url;
  final String referer;
  final BoxFit fit;
  final String sourceId;

  SoupImage(
      {Key key, this.url, this.referer, this.sourceId, this.fit = BoxFit.cover})
      : super(key: key);

  @override
  _SoupImageState createState() => _SoupImageState();
}

class _SoupImageState extends State<SoupImage> {
  Future<String> cookies;

  @override
  void initState() {
    super.initState();
    cookies = getCookies();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: cookies,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          if (snapshot.hasData) {
            return mainBody(snapshot.data);
          } else if (snapshot.hasError) {
            return mainBody("");
          } else {
            return CupertinoActivityIndicator();
          }
        });
  }

  Widget mainBody(String cookies) {
    return Container(
      child: CachedNetworkImage(
        memCacheHeight: (300 * 1.5).toInt(),
        memCacheWidth: 300,
        imageUrl: (!widget.url.contains("https:https:"))
            ? widget.url
            : widget.url.replaceFirst("https:", ""),
        httpHeaders: prepareHeaders(cookies),
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
        fit: widget.fit,
      ),
    );
  }

  Map<String, String> prepareHeaders(String cookies) {
    Map<String, String> headers = Map();

    if (widget.referer != null && widget.referer.isNotEmpty)
      headers.putIfAbsent("Referer", () => widget.referer ?? imageHeaders(widget.url));

    if (cookies.isNotEmpty) {
      headers.putIfAbsent("User-Agent", () => 'MangaSoup/0.0.3');
      headers.putIfAbsent("Cookie", () => cookies);
    }

    return headers;
  }

  Future<String> getCookies() async {
    try {
      Map info = await prepareAdditionalInfo(widget.sourceId);

      Map cookies = info['cookies'];

      if (cookies == null) return "";
      return stringifyCookies(cookies);
    } catch (err) {
      print(err);
      return "";
    }
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
