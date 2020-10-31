import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:collection/collection.dart';
import 'dart:ui';

import 'package:mangasoup_prototype_3/Services/test_preference.dart';
import 'package:provider/provider.dart';

class SourcesPage extends StatefulWidget {
  final String selector;

  const SourcesPage({Key key, this.selector}) : super(key: key);

  @override
  _SourcesPageState createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  ApiManager server = ApiManager();
  String _currentSelector;

  check() {
    if (widget.selector != null)
      _currentSelector = widget.selector;
    else {
      _currentSelector = "";
    }
  }

  // Retrieve Source from Server
  Future<Map> getSources() async {
    List<Source> sources =
        await server.getServerSources("live"); // Retrieve Source
    Map sorted =
        groupBy(sources, (Source obj) => obj.sourcePack); // Group Source
    return sorted;
  }

  selectSource(Source src) async {
    TestPreference _prefs = TestPreference();
    await _prefs.init();
    await _prefs.setSource(src);
    await Provider.of<SourceNotifier>(context, listen: false).loadSource(src);
    sourcesStream.add(src.selector);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else
      Navigator.pushReplacementNamed(context, 'landing');
  }

  @override
  void initState() {
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(450, 747.5), allowFontScaling: true);

    return Scaffold(
      body: FutureBuilder(
        future: getSources(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          if (snapshot.hasData) {
            Map sourcePacks = snapshot.data;
            List keys = sourcePacks.keys.toList();
            List values = sourcePacks.values.toList();
            return DefaultTabController(
              length: sourcePacks.length,
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Sources"),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(CupertinoIcons.info),
                      onPressed: () {},
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.purple,
                    labelColor: Colors.purple,
                    tabs: List<Widget>.generate(
                      sourcePacks.length,
                      (index) => Tab(
                        child: Text(
                          keys[index],
                          style: TextStyle(fontSize: 17.sp),
                        ),
                        // text: ,
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: List<Widget>.generate(
                    sourcePacks.length,
                    (int index) {
                      List<Source> _sources = values[index];
                      return Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: ScreenUtil().setWidth(10),
                              mainAxisSpacing: ScreenUtil().setWidth(10),
                              childAspectRatio: .77, // 77/100
                            ),
                            itemCount: _sources.length,
                            itemBuilder: (BuildContext context, int i) {
                              Source source = _sources[i];
                              return GestureDetector(
                                onTap: () async {
                                  if (!source.isEnabled)
                                    sourceDisabledDialog();
                                  else
                                    selectSource(source);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: (!source.isEnabled)
                                            ? Colors.red
                                            : (source.selector !=
                                                    _currentSelector)
                                                ? (source.vipProtected)
                                                    ? Colors.amber
                                                    : Colors.grey[900]
                                                : Colors.purple),
                                  ),
                                  child: GridTile(
                                    child: Image.network(source.thumbnail),

                                    // CachedNetworkImage(
                                    //   imageUrl: source.thumbnail,
                                    //   fadeInDuration:
                                    //       Duration(milliseconds: 200),
                                    //   placeholder: (context, url) => Center(
                                    //     child: CupertinoActivityIndicator(),
                                    //   ),
                                    // ),
                                    footer: Center(
                                      child: FittedBox(
                                        child: Text(
                                          source.name,
                                          style: TextStyle(
                                              fontSize: 17.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    header: (!source.vipProtected)
                                        ? Container()
                                        : Container(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.verified_sharp,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(
                                                  width: 3.w,
                                                ),
                                                Text(
                                                  "VIP",
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                      );
                    },
                  ),
                ),
              ),
            );
          } else
            return Scaffold(
              appBar: AppBar(
                title: Text("Sources"),
                centerTitle: true,
              ),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Center(
                    child: InkWell(
                      child: Text(
                        "An Error Occurred\n ${snapshot.error}\nTap to Retry",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            );
        },
      ),
    );
  }

  sourceDisabledDialog() {
    return showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text("Source Disabled"),
              content: Text("This source has been disabled for maintenance"),
              actions: [
                PlatformDialogAction(
                  child: PlatformText("OK"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
