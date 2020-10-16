import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/test_preference.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Source> sources = [];
  int segmentedControlGroupValue = 0;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("For You"),
    1: Text("Home"),
    2: Text("Latest"),
  };

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(450, 747.5), allowFontScaling: true);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.cloud),
            onPressed: () {},
          ),
          title: Text("Discover"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30.h),
            child: PlatformWidget(
              cupertino: (_, __) => CupertinoSlidingSegmentedControl(
                  groupValue: segmentedControlGroupValue,
                  children: myTabs,
                  onValueChanged: (i) {
                    setState(() {
                      segmentedControlGroupValue = i;
                    });
                  }),
              material: (_, __) => TabBar(
                indicatorColor: Colors.transparent,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontSize: 17.sp),
                tabs: <Widget>[
                  Tab(
                    text: "For You",
                  ),
                  Tab(
                    text: "Home",
                  ),
                  Tab(
                    text: "Latest",
                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          // physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              color: Colors.grey,
            ),
            Container(
              color: Colors.blueGrey[800],
              child: Center(
                child: (sources.length == 0)
                    ? CupertinoButton(
                        child: Text("TEST"),
                        onPressed: simulate,
                      )
                    : Container(
                        child: GridView.builder(
                            itemCount: sources.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4),
                            itemBuilder: (context, index) {
                              Source source = sources[index];
                              return GridTile(
                                footer: Text(source.name),
                                child: Image.network(source.thumbnail),
                              );
                            }),
                      ),
              ),
            ),
            Container(
                child: CupertinoButton(
              child: Text("RETRIEVE"),
              onPressed: () {
                debugPrint(MediaQuery.of(context).size.width.toString());
              },
            ))
          ],
        ),
      ),
    );

    //   DefaultTabController(
    //   initialIndex: 1,
    //   length: 3,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text("Discover"),
    //       centerTitle: true,
    //       actions: [
    //         IconButton(
    //           icon: Icon(CupertinoIcons.cloud),
    //           onPressed: () {
    //
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.search),
    //           onPressed: () {
    //             debugPrint('Go To Search Page');
    //           },
    //           color: Colors.white,
    //         ),
    //       ],
    //       bottom: PreferredSize(
    //         preferredSize: Size.fromHeight(ScreenUtil().setHeight(30)),
    //         child:

    //       ),
    //     ),
    //
    // );
  }

  simulate() async {
    ApiManager re = ApiManager();
    // await re.getAll("mangadex", "9", 1, {});
    // List x = await re.getServerSources("live");
    // setState(() {
    //   sources = x;
    // });

    TestPreference _t = TestPreference();
    await _t.init();
    _t.setName("tester");

    debugPrint("OK");
  }

  retrieve() async {
    TestPreference _t = TestPreference();
    await _t.init();
    String y = _t.getName();
    debugPrint(y);
  }
}
