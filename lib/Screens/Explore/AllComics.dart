import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:provider/provider.dart';

class AllComicsPage extends StatefulWidget {
  @override
  _AllComicsPageState createState() => _AllComicsPageState();
}

class _AllComicsPageState extends State<AllComicsPage>
    with AutomaticKeepAliveClientMixin {
  Map _sort = {"Name": "Default", "Selector": "default"};
  Future<List<ComicHighlight>> _futureComics;
  List<ComicHighlight> _comics;
  int _page = 1;
  ScrollController _controller;
  bool _loadingMore = false;

  Future<List<ComicHighlight>> _loadComics(
      String source, String sortBy, int page, Map info) async {
    ApiManager _manager = ApiManager();
    List<ComicHighlight> c;
    try {
      c = await _manager.getAll(source, sortBy, page);
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return c;
  }

  Future<void> paginate() async {
    if (_loadingMore == true) return null;
    _page++;
    setState(() {
      _loadingMore = true;
    });
    List<ComicHighlight> t = List();
    try {
      t = await _loadComics(
          Provider.of<SourceNotifier>(context, listen: false).source.selector,
          _sort['selector'],
          _page, {});
      setState(() {
        _comics.addAll(t);
        _loadingMore = false;
      });
    } catch (err) {
      showSnackBarMessage("Failed to load more");
    }
  }

  @override
  void initState() {
    super.initState();
    Source _source = Provider.of<SourceNotifier>(context, listen: false).source;
    _sort = _source.sorters[0];

    _futureComics = _loadComics(_source.selector, _sort["selector"], _page, {});

    _controller = ScrollController();
    _controller.addListener(() {
      _scrollListener();
    });
    sourcesStream.stream.listen((event) {
      print("loading homepage");
      _page = 1;
      Source _source =
          Provider.of<SourceNotifier>(context, listen: false).source;
      _sort = _source.sorters[0];
      _futureComics =
          _loadComics(_source.selector, _sort["selector"], _page, {});
    });
  }

  _scrollListener() async {
    double maxScroll = _controller.position.maxScrollExtent;
    double currentScroll = _controller.position.pixels;
    double delta = MediaQuery.of(context).size.height * .65;
    if (maxScroll - currentScroll < delta) {
      await paginate();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<SourceNotifier>(
      builder: (context, sourceProvider, _) => FutureBuilder(
          future: _futureComics,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: InkWell(
                  child: Text(
                    "${snapshot.error}\nTap to Retry",
                    style: notInLibraryFont,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    setState(() {
                      _futureComics = _loadComics(
                          sourceProvider.source.selector,
                          _sort["selector"],
                          _page, {});
                    });
                  },
                ),
              );
            }
            if (snapshot.hasData) {
              _comics = snapshot.data;
              return SingleChildScrollView(
                controller: _controller,
                physics: BouncingScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                  fontSize: 20,
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                child: Text(
                                  // _sort['Name']
                                  _sort['name'] ?? "",
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20,
                                  ),
                                ),
                                onTap: () {
                                  showPlatformModalSheet(
                                    context: context,
                                    builder: (_) => PlatformWidget(
                                      material: (_, __) => ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: sourceProvider
                                            .source.sorters.length,
                                        itemBuilder:
                                            (BuildContext context, index) =>
                                                ListTile(
                                          title: Text(
                                            sourceProvider.source.sorters[index]
                                                ['name'],
                                          ),
                                          leading: Icon(
                                            Icons.check,
                                            color: (_sort['selector'] ==
                                                    sourceProvider.source
                                                            .sorters[index]
                                                        ['selector'])
                                                ? Colors.purple
                                                : Colors.transparent,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _sort = sourceProvider
                                                  .source.sorters[index];
                                              _futureComics = _loadComics(
                                                  sourceProvider
                                                      .source.selector,
                                                  _sort['selector'],
                                                  1,
                                                  {});
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ),
                                      cupertino: (_, __) =>
                                          CupertinoActionSheet(
                                            title: Text(
                                          "Sort by",
                                        ),
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                          child: Text("Cancel"),
                                          isDestructiveAction: true,
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                        actions: List<
                                            CupertinoActionSheetAction>.generate(
                                          sourceProvider.source.sorters.length,
                                          (index) => CupertinoActionSheetAction(
                                            onPressed: () {
                                              setState(() {
                                                _sort = sourceProvider
                                                    .source.sorters[index];
                                                _futureComics = _loadComics(
                                                    sourceProvider
                                                        .source.selector,
                                                    _sort['selector'],
                                                    1,
                                                    {});
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  sourceProvider.source
                                                      .sorters[index]['name'],
                                                ),
                                                Spacer(),
                                                Icon(
                                                  _sort['selector'] ==
                                                          sourceProvider.source
                                                                  .sorters[
                                                              index]['selector']
                                                      ? CupertinoIcons
                                                          .check_mark
                                                      : null,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: ComicGrid(comics: _comics),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (_loadingMore)
                          ? LoadingIndicator()
                          : CupertinoButton(
                              child: Text("Load More"),
                              onPressed: () => paginate(),
                            ),
                    ],
                  ),
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
