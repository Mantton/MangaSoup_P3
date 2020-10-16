import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:collection/collection.dart';
import 'dart:ui';

class SourcesPage extends StatefulWidget {
  @override
  _SourcesPageState createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  ApiManager server = ApiManager();

  // Retrieve Source from Server
  Future<Map> getSources() async {
    List<Source> sources =
        await server.getServerSources("live"); // Retrieve Source
    Map sorted =
        groupBy(sources, (Source obj) => obj.sourcePack); // Group Source
    return sorted;
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
                              childAspectRatio: ScreenUtil().setHeight(77) /
                                  ScreenUtil().setWidth(100), // 77/100
                            ),
                            itemCount: _sources.length,
                            itemBuilder: (BuildContext context, int i) {
                              Source source = _sources[i];
                              return GestureDetector(
                                onTap: () {
                                  debugPrint(source.thumbnail);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: (!source.isEnabled)
                                            ? Colors.red
                                            : (source.selector !=
                                                    'mangadex') // todo change to active source
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
                                            fontWeight: FontWeight.bold
                                          ),
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
            // todo, raise error here
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
                        "An Error Occurred \n Tap to Retry",
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
}
