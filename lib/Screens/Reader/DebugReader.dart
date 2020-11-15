import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class DebugReader extends StatefulWidget {
  final List<Chapter> chapters;
  final bool downloaded;
  final Chapter selectedChapter;
  final String selector;
  final ChapterDownloadObject cdo;

  const DebugReader({
    Key key,
    this.chapters,
    this.downloaded = false,
    this.selectedChapter,
    @required this.selector,
    this.cdo,
  }) : super(key: key);

  @override
  _DebugReaderState createState() => _DebugReaderState();
}

class _DebugReaderState extends State<DebugReader> {
  ApiManager _manager = ApiManager();

  Future<bool> init(Chapter chapter) async {
    if (widget.downloaded) {
      ImageChapter c = ImageChapter(
        images: widget.cdo.images,
        source: widget.cdo.highlight.source,
        referer: widget.cdo.highlight.imageReferer,
        count: widget.cdo.images.length,
      );
      loadedChapters.add(c);
    } else
      loadedChapters
          .add(await _manager.getImages(widget.selector, chapter.link));
    return true;
  }

  Future<ImageChapter> getImages(Chapter chapter) async {
    return _manager.getImages(widget.selector, chapter.link);
  }

  Future<bool> initializer;
  List<ImageChapter> loadedChapters = List();
  bool vertical = true;

  @override
  void initState() {
    super.initState();
    initializer = init(widget.selectedChapter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Reader"),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_left_rounded),
            onPressed: () {
              setState(() {
                vertical = !vertical;
              });
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: initializer,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Internal Error"),
              );
            }
            if (snapshot.hasData)
              return home();
            else {
              return Center(child: Text("Critical Error,"));
            }
          }),
    );
  }

  Widget home() {
    return Container(
      child: ListView(
        scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
        shrinkWrap: true,
        children: loadedChapters
            .map(
              (chapter) => ListView(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
                shrinkWrap: true,
                children: chapter.images
                    .map(
                      (image) => Container(
                        // padding: EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: (!widget.downloaded)
                            ? SoupImage(
                                url: image,
                                referer: chapter.referer,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                File(
                                  image,
                                ),
                                fit: BoxFit.fill,
                              ),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}
