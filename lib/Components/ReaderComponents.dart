import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/constants/variables.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../Globals.dart';

class ReaderImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final String referer;
  final String sourceId;

  const ReaderImage({
    Key key,
    this.url,
    this.fit = BoxFit.fitWidth,
    this.referer,
    @required this.sourceId,
  }) : super(key: key);

  @override
  _ReaderImageState createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Matrix4> _animation;
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {});
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 140),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  TapDownDetails _doubleTapDetails;

  @override
  Widget build(BuildContext context) {
    _transformationController.value = Matrix4.identity();

    void _handleDoubleTap() {
      Matrix4 _endMatrix;
      Offset _position = _doubleTapDetails.localPosition;

      if (_transformationController.value != Matrix4.identity()) {
        _endMatrix = Matrix4.identity();
      } else {
        _endMatrix = Matrix4.identity()
          ..translate(-_position.dx * 2, -_position.dy * 2)
          ..scale(3.0);
      }

      _animation = Matrix4Tween(
        begin: _transformationController.value,
        end: _endMatrix,
      ).animate(
        CurveTween(curve: Curves.easeOut).animate(_animationController),
      );
      _animationController.forward(from: 0);
    }

    void _handleDoubleTapDown(TapDownDetails details) {
      _doubleTapDetails = details;
    }

    return Center(
      child: Consumer<PreferenceProvider>(
        builder: (BuildContext c, provider, _) => GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: VisibilityDetector(
            key: Key("${widget.url}"),
            onVisibilityChanged: (i) =>
                _transformationController.value = Matrix4.identity(),
            // reset on visibility change
            child: InteractiveViewer(
              transformationController: _transformationController,
              maxScale: 3.5,
              minScale: 1,
              panEnabled: true,
              clipBehavior: Clip.none,
              child: Container(
                child: MainImageWidget(
                  url: widget.url,
                  referer: widget.referer,
                  fit: widget.fit,
                  maxWidth: provider.readerMaxWidth,
                  sourceId: widget.sourceId,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// scrollDirection: Axis.horizontal,
// physics:
// _transformationController.value == Matrix4.identity()
// ? null
// : AlwaysScrollableScrollPhysics(),
//width: _transformationController.value == Matrix4.identity()?null:MediaQuery.of(context).size.width,
class MainImageWidget extends StatefulWidget {
  const MainImageWidget({
    Key key,
    @required this.url,
    @required this.referer,
    @required this.fit,
    @required this.sourceId,
    this.maxWidth = false,
  }) : super(key: key);

  final String url;
  final String referer;
  final BoxFit fit;
  final String sourceId;
  final bool maxWidth;

  @override
  _MainImageWidgetState createState() => _MainImageWidgetState();
}

class _MainImageWidgetState extends State<MainImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height,
      width: widget.maxWidth ? MediaQuery.of(context).size.width : null,
      child: (!widget.url.contains(msDownloadFolderName))
          ? urlCaller()
          : Image.file(
              File(Provider.of<PreferenceProvider>(context).paths + widget.url),
              errorBuilder: (_, err, trace) => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.purple,
                      ),
                      Text(
                        "Unable to decode downloaded image data.",
                        style: textFieldStyle,
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget urlCaller() {
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

        imageUrl: (!widget.url.contains("https:https:"))
            ? widget.url
            : widget.url.replaceFirst("https:", ""),
        progressIndicatorBuilder: (_, url, var progress) =>
            progress.progress != null
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularPercentIndicator(
                        radius: 45.0,
                        lineWidth: 3.0,
                        percent: progress.progress,
                        progressColor: Colors.purple,
                        backgroundColor: Colors.grey[900],
                        // fillColor: Colors.grey[900],
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text(
                          "Loading...",
                          style: notInLibraryFont,
                        ),
                      ),
                    ),
                  ),
        httpHeaders: widget.referer != null
            ? {
                "User-Agent": 'MangaSoup/0.0.3',
                "Cookie": cookies,
                "referer": widget.referer ?? imageHeaders(widget.url)
              }
            : null,

        errorWidget: (context, url, error) => Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.purple,
              ),
            ),
          ),
        ),
        fit: widget.fit,
        fadeInDuration: Duration(microseconds: 500),
        fadeInCurve: Curves.easeIn,
      ),
    );
  }

  Future<String> getCookies() async {
    Map info = await prepareAdditionalInfo(widget.sourceId);

    Map cookies = info['cookies'];

    if (cookies == null) return "";
    return stringifyCookies(cookies);
  }

  String stringifyCookies(Map cookies) =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
}

class VioletImage extends StatefulWidget {
  final String url;
  final String referer;
  final BoxFit fit;

  const VioletImage({Key key, this.url, this.referer, this.fit})
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
    return await _calculateNetworkImageDimension(widget.url, widget.referer);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _getDimensions,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: VioletPage(
              url: widget.url,
              referer: widget.referer,
              fit: widget.fit,
              size: snapshot.data,
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

class VioletPage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final String referer;
  final Size size;

  const VioletPage({Key key, this.url, this.fit, this.referer, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double proportionalHeight =
        MediaQuery.of(context).size.width / size.aspectRatio;

    return Container(
      width: size.width,
      height: proportionalHeight,
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          url,
          headers: referer != null ? {"referer": referer} : null,
        ),
        errorBuilder: (context, _, trace) => IconButton(
          icon: Icon(Icons.error),
          onPressed: null,
        ),
      ),
    );
  }
}
