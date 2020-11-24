import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/DownloadProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Reader/Readers/MangaReader.dart';
import 'package:mangasoup_prototype_3/Screens/Reader/Readers/VerticalReader.dart';
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
    ImageChapter initialChapter;
    if (widget.downloaded) {
      initialChapter = ImageChapter(
        images: widget.cdo.images,
        source: widget.cdo.highlight.source,
        referer: widget.cdo.highlight.imageReferer,
        count: widget.cdo.images.length,
      );
    } else
      initialChapter = await _manager.getImages(widget.selector, chapter.link);
    Provider.of<ReaderProvider>(context, listen: false)
        .initChapter(initialChapter);
    print("Initialized");
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
    Provider.of<ReaderProvider>(context, listen: false).selectedChapter =
        widget.selectedChapter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializer,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: LoadingIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  "Internal Error \n ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return Scaffold(
              body: SafeArea(
                child: body(),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text("Critical Error,"),
              ),
            );
          }
        });
  }

  Widget body() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Container(),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Container(child: Consumer<ReaderProvider>(
            builder: (BuildContext context, provider, _) {
              int mode = provider.readerMode;
              if (mode == 0)
                return MangaReader(
                  page: Provider.of<ReaderProvider>(context).page,
                );
              else if (mode == 1)
                return WebtoonReader();
              else if (mode == 2)
                return VerticalReader(
                  page: Provider.of<ReaderProvider>(context).page,
                );
              else
                return MangaReader();
            },
          )
              // WebtoonReader(),
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
              height: 55.h,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.grey,
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
                          color: Colors.grey,
                          size: 30.sp,
                        ),
                        onPressed: () async {
                          await settingsDialog();
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
              color: Colors.grey[900],
            ),
            Container(
              height: 60,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 7,
                    fit: FlexFit.tight,
                    child: Container(
                      child: Text(
                        Provider.of<ComicHighlightProvider>(context)
                            .highlight
                            .title,
                        style: TextStyle(color: Colors.grey, fontSize: 18.sp),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[900],
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          // todo: show chapters
                        },
                        child: Text(
                          '${Provider
                              .of<ReaderProvider>(context)
                              .selectedChapter
                              .name} ▼',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Roboto",
                          ),
                          textAlign: TextAlign.right,
                        ),
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
                  color: Colors.grey,
                ),
              ),
              Spacer(),
              Container(
                child: Text(
                  'Page ${Provider
                      .of<ReaderProvider>(context)
                      .page}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    fontFamily: 'Lato',
                    color: Colors.grey,
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
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  settingsDialog() {
    showPlatformDialog(
      context: context,
      builder: (context) =>
          PlatformAlertDialog(
            material: (_, __) =>
                MaterialAlertDialogData(
                  backgroundColor: Colors.black,
                ),
            content: Container(
              padding: EdgeInsets.all(7.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 22,
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Colors.grey[900],
                    indent: 10,
                    endIndent: 10,
                  ),
                  // Reading Mode
                  /// Options
                  ///
                  readerModeSetting(),

                  (Provider
                      .of<ReaderProvider>(context)
                      .readerMode == 0)
                      ? mangaModeOptions()
                      : Container(),
                ],
              ),
            ),
          ),
    );
  }

  Widget readerModeSetting() {
    return Row(
      children: [
        Text("Reader Mode"),
        SizedBox(
          width: 10.h,
        ),
        Spacer(),
        Consumer<ReaderProvider>(builder: (context, provider, _) {
          Map options = provider.readerModeOptions;
          List<MapEntry> rOptions = options.entries.toList();

          return Container(
            padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[900],
              border: Border.all(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                items: rOptions
                    .map(
                      (e) =>
                      DropdownMenuItem(
                        child: Text(
                          e.value,
                          style: TextStyle(fontSize: 17.sp),
                        ),
                        value: e,
                      ),
                )
                    .toList(),
                dropdownColor: Colors.grey[900],
                value:
                rOptions[Provider
                    .of<ReaderProvider>(context)
                    .readerMode],
                onChanged: (value) {
                  Provider.of<ReaderProvider>(context, listen: false)
                      .setReaderMode(value.key);
                },
              ),
            ),
          );
        })
      ],
    );
  }

  Widget mangaModeOptions() {
    return Container(
      margin: EdgeInsets.only(top: 15.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Manga Mode Settings",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 19,
            ),
          ),
          Divider(
            thickness: 3,
            color: Colors.grey[900],
            indent: 10,
            endIndent: 10,
          ),

          /// Orientation
          Row(
            children: [
              Text("Orientation"),
              SizedBox(
                width: 25.h,
              ),
              Spacer(),
              Consumer<ReaderProvider>(builder: (context, provider, _) {
                Map options = provider.orientationOptions;
                List<MapEntry> rOptions = options.entries.toList();

                return Container(
                  padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[900],
                      border: Border.all()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      items: rOptions
                          .map(
                            (e) =>
                            DropdownMenuItem(
                              child: Text(
                                e.value,
                                style: TextStyle(fontSize: 17.sp),
                              ),
                              value: e,
                            ),
                      )
                          .toList(),
                      dropdownColor: Colors.grey[900],
                      value: rOptions[
                      Provider
                          .of<ReaderProvider>(context)
                          .orientationMode],
                      onChanged: (value) {
                        Provider.of<ReaderProvider>(context, listen: false)
                            .setOrientationMode(value.key);
                      },
                    ),
                  ),
                );
              })
            ],
          ),
          SizedBox(
            height: 5.h,
          ),

          /// Scroll Direction
          Column(
            children: [
              Row(
                children: [
                  Text("Scroll Direction"),
                  SizedBox(
                    width: 9.h,
                  ),
                  Spacer(),
                  Consumer<ReaderProvider>(builder: (context, provider, _) {
                    Map options = provider.orientationMode == 0
                        ? provider.scrollDirectionOptionsHorizontal
                        : provider.scrollDirectionOptionsVertical;
                    List<MapEntry> rOptions = options.entries.toList();

                    return Container(
                      padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[900],
                        border: Border.all(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: rOptions
                              .map(
                                (e) =>
                                DropdownMenuItem(
                                  child: Text(
                                    e.value,
                                    style: TextStyle(fontSize: 17.sp),
                                  ),
                                  value: e,
                                ),
                          )
                              .toList(),
                          dropdownColor: Colors.grey[900],
                          value: rOptions[Provider
                              .of<ReaderProvider>(context)
                              .scrollDirectionMode],
                          onChanged: (value) {
                            Provider.of<ReaderProvider>(context, listen: false)
                                .setScrollDirectionMode(value.key);
                          },
                        ),
                      ),
                    );
                  })
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
