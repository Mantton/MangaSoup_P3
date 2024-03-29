import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:provider/provider.dart';

import '../../Globals.dart';

class LatestPage extends StatefulWidget {
  @override
  _LatestPageState createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<ComicHighlight>> _futureComics;
  List<ComicHighlight> _comics;
  int _page = 1;
  ScrollController _controller;
  bool _loadingMore = false;

  Future<List<ComicHighlight>> _loadComics(String source, int page) async {
    ApiManager _manager = ApiManager();
    List<ComicHighlight> c;
    try {
      c = await _manager.getLatest(source, page);
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
          _page);
      if (t != null) {
        setState(() {
          _comics.addAll(t);
          _loadingMore = false;
        });
      }
    } catch (err) {
      showSnackBarMessage("Unable to Paginate");
    }
  }

  @override
  void initState() {
    super.initState();
    Source _source = Provider.of<SourceNotifier>(context, listen: false).source;
    _futureComics = _loadComics(_source.selector, _page);
    _controller = ScrollController();
    _controller.addListener(() {
      _scrollListener();
    });
    sourcesStream.stream.listen((event) {
      Source _source =
          Provider.of<SourceNotifier>(context, listen: false).source;
      _futureComics = _loadComics(_source.selector, _page);
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
                      _futureComics =
                          _loadComics(sourceProvider.source.selector, _page);
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
                      ComicGrid(comics: _comics),
                      SizedBox(
                        height: 10.h,
                      ),
                      (_comics.isNotEmpty)
                          ? (_loadingMore)
                              ? LoadingIndicator()
                              : CupertinoButton(
                                  child: Text("Load More"),
                                  onPressed: () => paginate(),
                                )
                          : Container(),
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
