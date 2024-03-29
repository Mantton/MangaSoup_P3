import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';
import 'package:mangasoup_prototype_3/Providers/BrowseProvider.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/mangadex_login.dart';
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
  bool enabled = false;

  Future<bool> start() async {
    if (Provider.of<SourceNotifier>(context, listen: false).source.filters !=
        null) {
      await Provider.of<BrowseProvider>(context, listen: false).init(
          Provider.of<SourceNotifier>(context, listen: false).source.filters);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Browse"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: Provider.of<SourceNotifier>(context, listen: false)
                          .source
                          .filters !=
                      null
                  ? showFilters
                  : null,
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder(
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
                                "This Source does not support the browse feature",
                              ),
                            ),
                          ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    child: LoadingIndicator(),
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
          ),
        ));
  }

  showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (_) => buildFilters(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget skeleton(List sourceFilters) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
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
            return Center(
              child: LoadingIndicator(),
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
                          builder: (_) => MangaDexLogin(),
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

  buildFilters() => Container(
        height: MediaQuery.of(context).size.height * .75,
        color: Color.fromRGBO(9, 9, 9, .95),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Filters",
                          style: TextStyle(fontFamily: "Roboto", fontSize: 30),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 30,
                            color: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    flex: 7,
                    child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                Provider.of<SourceNotifier>(context)
                                    .source
                                    .filters
                                    .length,
                                (index) => TesterFilter(
                                  filter: SourceSetting.fromMap(
                                    Provider.of<SourceNotifier>(context)
                                        .source
                                        .filters[index],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(3.0),
                      child: ElevatedButton(
                        // height: 40,

                        onPressed: () {
                          Navigator.pop(context);
                          queryMap = Provider.of<BrowseProvider>(context,
                                  listen: false)
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
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple.shade700,
                          onPrimary: Colors.white,
                          minimumSize: Size(100, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
