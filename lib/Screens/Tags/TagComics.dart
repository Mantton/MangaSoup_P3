import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:provider/provider.dart';

class TagComicsPage extends StatefulWidget {
  final Tag tag;
  final List sorters;

  const TagComicsPage({Key key, @required this.tag, this.sorters})
      : super(key: key);

  @override
  _TagComicsPageState createState() => _TagComicsPageState();
}

class _TagComicsPageState extends State<TagComicsPage> {
  Map _sort = {"name": "Default", "selector": ""};
  Future<List<ComicHighlight>> _futureComics;
  List<ComicHighlight> _comics;
  int _page = 1;
  ScrollController _controller;
  bool _loadingMore = false;

  Future<List<ComicHighlight>> _loadComics(String sort, int page) async {
    print(widget.tag.toMap());
    ApiManager _manager = ApiManager();
    return await _manager.getTagComics(
        widget.tag.selector, page, widget.tag.link, sort);
  }

  Future<List<ComicHighlight>> paginate() {
    if (_loadingMore == true) return null;
    _page++;
    setState(() {
      _loadingMore = true;
    });
    return _loadComics(_sort['selector'], _page);
  }

  @override
  void initState() {
    super.initState();
    print("Starting");
    Source _source = Provider.of<SourceNotifier>(context, listen: false).source;
    if (_source.selector == widget.tag.selector) _sort = _source.sorters[0];
    _futureComics = _loadComics(_sort["selector"], _page);

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
          _comics.addAll(y);
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        centerTitle: true,
      ),
      body: Consumer<SourceNotifier>(
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
                      "An error occurred\n ${snapshot.error}\nTap to Retry",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      setState(() {
                        _futureComics = _loadComics(_sort["selector"], _page);
                      });
                    },
                  ),
                );
              }
              if (snapshot.hasData) {
                _comics = snapshot.data;
                return SingleChildScrollView(
                  controller: _controller,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: [
                                Text(
                                  widget.tag.name,
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
                                    (sourceProvider.source.selector == widget.tag.selector)?showPlatformModalSheet(
                                      context: context,
                                      builder: (_) => PlatformWidget(
                                        material: (_, __) => ListView.builder(
                                          itemCount: sourceProvider
                                              .source.sorters.length,
                                          itemBuilder:
                                              (BuildContext context, index) =>
                                                  ListTile(
                                            title: Text(
                                              sourceProvider.source
                                                  .sorters[index]['name'],
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
                                                    _sort["selector"], _page);
                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                        ),
                                        cupertino: (_, __) =>
                                            CupertinoActionSheet(
                                          title: Text("Sort by"),
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            child: Text("Cancel"),
                                            isDestructiveAction: true,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          actions: List<
                                              CupertinoActionSheetAction>.generate(
                                            sourceProvider
                                                .source.sorters.length,
                                            (index) =>
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                setState(() {
                                                  _sort = sourceProvider
                                                      .source.sorters[index];
                                                  _futureComics = _loadComics(
                                                      _sort["selector"], _page);
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
                                                  Icon(_sort['selector'] ==
                                                          sourceProvider.source
                                                                  .sorters[
                                                              index]['selector']
                                                      ? CupertinoIcons
                                                          .check_mark
                                                      : null)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ): showSnackBarMessage("Cannot View Sorters from different source");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        ComicGrid(comics: _comics),
                        SizedBox(
                          height: 10.h,
                        ),
                        (_loadingMore) ? LoadingIndicator() : Container(),
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
      ),
    );
  }
}
