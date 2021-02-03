import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/util/viewer_gateway.dart';
import 'package:provider/provider.dart';

class ReaderHome extends StatefulWidget {
  final List<Chapter> chapters;
  final int initialChapterIndex;
  final String selector;

  const ReaderHome(
      {Key key, this.chapters, this.initialChapterIndex, this.selector})
      : super(key: key);

  @override
  _ReaderHomeState createState() => _ReaderHomeState();
}

class _ReaderHomeState extends State<ReaderHome> {
  Future providerInitializer;
  @override
  void initState() {
    providerInitializer = Provider.of<ReaderProvider>(context, listen: false)
        .init(widget.chapters, widget.initialChapterIndex, widget.selector);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: providerInitializer,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return ReaderFrame();
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(
              child: LoadingIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ReaderFrame extends StatefulWidget {
  @override
  _ReaderFrameState createState() => _ReaderFrameState();
}

class _ReaderFrameState extends State<ReaderFrame> {
  bool _showControls = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            plain(),
            ViewerGateway(),
            header(),
            footer(),
          ],
        ),
      ),
    );
  }

  Widget plain() => GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Container(),
      );

  Widget header() {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
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
                            onPressed: () {}),
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
                          "${provider.currentChapterName}",
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
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget footer() {
    return Consumer<ReaderProvider>(
        builder: (context, provider, _) {
          return AnimatedPositioned(
            duration: Duration(milliseconds: 150),
            curve: Curves.ease,
            bottom: _showControls ? 0 : -60.h,
            child: Container(
              height: 60.h,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {},
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey,
                      ),
                    ),
                    Spacer(),
                    provider.pageDisplayNumber != null ? Text(
                        "${provider.pageDisplayNumber}/${provider
                            .pageDisplayCount}") : Container(),
                    Spacer(),
                    IconButton(
                      onPressed: () async {},
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
