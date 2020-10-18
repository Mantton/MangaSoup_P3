import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class LatestPage extends StatefulWidget {
  @override
  _LatestPageState createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  Future<List<ComicHighlight>> test;
  List<ComicHighlight> k;
  ScrollController _controller;
  bool loadingMore = false;

  Future<List<ComicHighlight>> loadComics() async {
    ApiManager _manager = ApiManager();
    return await _manager.getLatest(
        Provider.of<SourceNotifier>(context, listen: false).source.selector,
        page);
  }

  Future<List<ComicHighlight>> paginate() async {
    if (loadingMore == true) return null;
    page++;
    return await loadComics();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      test = loadComics();
    });
    _controller = ScrollController();
    _controller.addListener(() {
      _scrollListener();
    });
  }

  _scrollListener() async {
    double maxScroll = _controller.position.maxScrollExtent;
    double currentScroll = _controller.position.pixels;
    double delta = MediaQuery.of(context).size.height * .65;
    if (maxScroll - currentScroll < delta) {
      List<ComicHighlight> y = await paginate();
      if (y != null) {
        setState(() {
          k.addAll(y);
          loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SourceNotifier>(
      builder: (context, sourceProvider, _) => FutureBuilder(
          future: test,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasData) {
              k = snapshot.data;
              return SingleChildScrollView(
                controller: _controller,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ComicGrid(comics: k),
                      SizedBox(
                        height: 10.h,
                      ),
                      (loadingMore) ? LoadingIndicator() : Container(),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: InkWell(
                  child: Text(
                    "Retry Fetch",
                    style: TextStyle(fontSize: 15.sp),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    setState(() {});
                  },
                ),
              );
            } else {
              return Center(
                child: InkWell(
                  child: LoadingIndicator(),
                  onTap: () {
                    setState(() {});
                  },
                ),
              );
            }
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
