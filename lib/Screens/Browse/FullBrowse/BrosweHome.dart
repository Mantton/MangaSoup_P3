import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';
import 'package:mangasoup_prototype_3/Providers/BrowseProvider.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/MangaDex/DexLogin.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:provider/provider.dart';

import 'FilterWidgets.dart';

class BrowsePage extends StatefulWidget {
  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  Map queryMap = Map();
  bool filters = true;
  Future<List<ComicHighlight>> results;

  Future<List<ComicHighlight>> getResults() async {
    ApiManager _manager = ApiManager();
    return await _manager.browse(
        Provider.of<SourceNotifier>(context, listen: false).source.selector,
        queryMap);
  }

  toggleFilters() {
    setState(() {
      filters = !filters;
    });
  }

  @override
  void initState() {
    init = start();
    super.initState();
  }

  Future<bool> init;

  Future<bool> start() async {
    if (Provider.of<SourceNotifier>(context, listen: false).source.filters !=
        null) {
      Provider.of<BrowseProvider>(context, listen: false).init(
          Provider.of<SourceNotifier>(context, listen: false).source.filters);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Browse"),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(Icons.filter_alt), onPressed: showFilters)
          ],
        ),
        body: FutureBuilder(
          future: init,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return Consumer<SourceNotifier>(
                builder: (context, provider, _) => Container(
                  child: (provider.source.filters != null)
                      ? Container(
                          child: skeleton(provider.source.filters),
                        )
                      : Container(
                          child: Center(
                            child: Text(
                                "This Source does not support the browse feature"),
                          ),
                        ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset("Assets/More/loading.gif"),
                      SizedBox(height: 10.h),
                      LoadingIndicator(),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Container(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        results = getResults();
                      });
                    },
                    child: Text(
                      "An Error Occurred \n ${snapshot.error} \n Tap to Retry",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: Text(
                    "Awaiting Filter Selection",
                    style: isEmptyFont,
                  ),
                ),
              );
            }
          },
        ));
  }

  showFilters() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (_, __, ___) => buildFilters(),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  Widget skeleton(List sourceFilters) {
    return Stack(
      children: [
        Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
        ),
        Positioned(
          child: Container(
            child: resultBody(),
          ),
        ),
      ],
    );
  }

  Widget resultBody() {
    return Container(
      child: FutureBuilder(
        future: results,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
                child: Column(
                  children: [
                    Image.asset("Assets/More/loading.gif"),
                    SizedBox(height: 10.h),
                    LoadingIndicator(),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            if (snapshot.error == MissingMangaDexSession) {
              return Center(
                child: CupertinoButton(
                    child: Text(
                      "You are not Logged in to MangaDex\n Tap to login",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MangadexLoginPage(),
                          fullscreenDialog: true,
                        ),
                      );

                      showSnackBarMessage(result);
                      setState(() {
                        results = getResults();
                      });
                    }),
              );
            } else {
              return Center(
                child: InkWell(
                  child: Text(
                    "An Error Occurred \n ${snapshot.error ?? ""} \n Tap to retry",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          }
          if (snapshot.hasData) {
            return (snapshot.data.length != 0)
                ? ComicGrid(comics: snapshot.data)
                : Container(
              child: Center(
                child: Text(
                  "No Results",
                  style: isEmptyFont,
                ),
              ),
            );
          } else {
            return Container(
              child: Center(
                child: Text(
                  "Awaiting Filter Selection",
                  style: isEmptyFont,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  buildFilters() =>
      Dialog(
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(17.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Filters",
                      style: TextStyle(fontFamily: "Roboto", fontSize: 30.sp),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: 30.w,
                        color: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Column(
                children: [
                  Column(
                    children: List.generate(
                      Provider
                          .of<SourceNotifier>(context)
                          .source
                          .filters
                          .length,
                          (index) =>
                          TesterFilter(
                            filter: SourceSetting.fromMap(
                                Provider
                                    .of<SourceNotifier>(context)
                                    .source
                                    .filters[index]),
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  MaterialButton(
                    height: 50.h,
                    minWidth: 100.w,
                    onPressed: () {
                      Navigator.pop(context);
                      queryMap =
                          Provider.of<BrowseProvider>(context, listen: false)
                              .encodedData;
                      print(queryMap);
                      // API SEARCH
                      setState(() {
                        results = getResults();
                        filters = false;
                      });
                    },
                    child: Text(
                      "Browse",
                      style: isEmptyFont,
                    ),
                    color: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}
