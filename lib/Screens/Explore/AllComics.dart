import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
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
  List<ComicHighlight> k = [];
  int page = 1;

  loadComics(String source, String sortBy, int page, Map info) async {
    ApiManager _manager = ApiManager();
    _manager.getAll(source, sortBy, page, info).then((value) {
      setState(() {
        k = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Source source =
          Provider.of<SourceNotifier>(context, listen: false).source;
      _sort = source.sorters[0];
      loadComics(source.selector, _sort['Selector'], page, {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Consumer<SourceNotifier>(
              builder: (context, sourceProvider, _) => Padding(
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
                          "",
                          style: TextStyle(
                              color: Colors.purple, fontSize: 20.sp),
                        ),
                        onTap: () {
                          showPlatformModalSheet(
                            context: context,
                            builder: (_) => PlatformWidget(
                              material: (_, __) => ListView.builder(
                                itemCount:
                                    sourceProvider.source.sorters.length,
                                itemBuilder: (BuildContext context, index) =>
                                    ListTile(
                                  title: Text(
                                    sourceProvider.source.sorters[index]
                                        ['Name'],
                                  ),
                                  leading: Icon(
                                    Icons.check,
                                    color: ("" ==
                                            sourceProvider.source
                                                .sorters[index]['Selector'])
                                        ? Colors.purple
                                        : Colors.transparent,
                                  ),
                                  onTap: () {
                                    // setState(() {
                                    //   _sort = sourceProvider
                                    //       .source.sorters[index];
                                    //   Navigator.pop(context);
                                    // });
                                  },
                                ),
                              ),
                              cupertino: (_, __) => CupertinoActionSheet(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ComicGrid(comics: k)
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
