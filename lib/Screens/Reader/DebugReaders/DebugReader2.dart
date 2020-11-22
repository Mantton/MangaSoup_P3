import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Reader/Readers/WebtoonReader.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:provider/provider.dart';

class DebugReader2 extends StatefulWidget {
  final List<Chapter> chapters;
  final bool downloaded;
  final Chapter selectedChapter;
  final String selector;
  final ChapterDownloadObject cdo;

  const DebugReader2({
    Key key,
    this.chapters,
    this.downloaded = false,
    this.selectedChapter,
    @required this.selector,
    this.cdo,
  }) : super(key: key);

  @override
  _DebugReader2State createState() => _DebugReader2State();
}

class _DebugReader2State extends State<DebugReader2> {
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
  int readerMode = 0;
  bool _showControls = false;

  @override
  void initState() {
    initializer = init(widget.selectedChapter);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
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
                return body();
              else {
                return Center(child: Text("Critical Error,"));
              }
            }),
      ),
    );
  }

  Widget body() {
    return Stack(
      children: [
        Container(),
        GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Container(
            color: Colors.grey,
            child: WebtoonReader(),
          ),
        ),
        header(),
        footer(),
      ],
    );
  }

  Widget header() {
    return AnimatedPositioned(
      duration: Duration(
        milliseconds: 150,
      ),
      top: _showControls ? 0 : -120.h,
      curve: Curves.easeIn,
      height: 120.h,
      width: MediaQuery.of(context).size.width,
      child: Container(
        alignment: Alignment.topCenter,
        color: Colors.black,
        height: 120.h,
        child: Column(
          children: <Widget>[
            Container(
//                            color: Colors.grey,
              height: 55.h,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Container(
//                                    color: Colors.red,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 50.w,
                      child: FlatButton(
                        child: Icon(
                          Icons.more_horiz,
                          color: Colors.purple,
                          size: 30.sp,
                        ),
                        onPressed: () {
                          // todo: show settings menu
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 2.w,
              height: 3.h,
              color: Colors.grey[800],
            ),
            Container(
//                            color: Colors.blueGrey,
              height: 60,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 250.w,
                    child: Text(
                      Provider.of<ComicHighlightProvider>(context)
                          .highlight
                          .title,
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  Spacer(),
                  Container(
//                    color: Colors.red,
                    width: 140.w,
                    child: GestureDetector(
                      onTap: () {
                        // todo: show chapters
                      },
                      child: Text(
                        'selected chapter ▼', // todo put selected chapter here
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 15.sp,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget footer() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 150),
      curve: Curves.ease,
      bottom: _showControls ? 0 : -60.h,
      child: Container(
        height: 60.h,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  // todo, move to previous chapter
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white70,
                ),
              ),
              Spacer(),
              Container(
                child: Text(
                  'Page', // todo add page number
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    fontFamily: 'Lato',
                    color: Colors.white70,
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  // todo, move to next page
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
