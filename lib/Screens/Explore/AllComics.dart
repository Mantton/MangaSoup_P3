import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:provider/provider.dart';

class AllComicsPage extends StatefulWidget {
  @override
  _AllComicsPageState createState() => _AllComicsPageState();
}

class _AllComicsPageState extends State<AllComicsPage>
    with AutomaticKeepAliveClientMixin {
  Map _sort;
  Future<List<ComicHighlight>> test;
  List<ComicHighlight> k;
  int page = 1;
  ScrollController _controller;
  bool loadingMore = false;

  Future<List<ComicHighlight>> tester(
      String source, String sortBy, int page, Map info) async {
    ApiManager _manager = ApiManager();
    return await _manager.getAll(source, sortBy, page, info);
  }

  loadComics(String source, String sortBy, int page, Map info) async {
    ApiManager _manager = ApiManager();
    _manager.getAll(source, sortBy, page, info).then((value) {
      setState(() {
        k = value;
      });
    });
  }

  Future<List<ComicHighlight>> paginate() {
    if (loadingMore == true) return null;
    page++;
    setState(() {
      loadingMore = true;
    });
    return tester(
        Provider.of<SourceNotifier>(context, listen: false).source.selector,
        _sort['Selector'],
        page, {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Source source =
          Provider.of<SourceNotifier>(context, listen: false).source;

      _sort = source.sorters[0];
      test = tester(source.selector, _sort['Selector'], page, {});

      // loadComics(source.selector, _sort['Selector'], page, {});
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
  bool get wantKeepAlive => true;

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
                      Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Container(
                          child: Row(
                            children: [
                              Text(
                                sourceProvider.source.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                child: Text(
                                  // _sort['Name']
                                  _sort['Name'],
                                  style: TextStyle(
                                      color: Colors.purple, fontSize: 20.sp),
                                ),
                                onTap: () {
                                  showPlatformModalSheet(
                                    context: context,
                                    builder: (_) => PlatformWidget(
                                      material: (_, __) => ListView.builder(
                                        itemCount: sourceProvider
                                            .source.sorters.length,
                                        itemBuilder:
                                            (BuildContext context, index) =>
                                                ListTile(
                                          title: Text(
                                            sourceProvider.source.sorters[index]
                                                ['Name'],
                                          ),
                                          leading: Icon(
                                            Icons.check,
                                            color: (_sort['Selector'] ==
                                                    sourceProvider.source
                                                            .sorters[index]
                                                        ['Selector'])
                                                ? Colors.purple
                                                : Colors.transparent,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _sort = sourceProvider
                                                  .source.sorters[index];
                                              test = tester(
                                                  sourceProvider
                                                      .source.selector,
                                                  _sort['Selector'],
                                                  1,
                                                  {});
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ),
                                      cupertino: (_, __) =>
                                          CupertinoActionSheet(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
