import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Explore/AllComics.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/test_preference.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<Source> sources = [];
  int segmentedControlGroupValue = 1;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("For You"),
    1: Text("Home"),
    2: Text("Latest"),
  };
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(450, 747.5), allowFontScaling: true);

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.cloud),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SourcesPage(
                    selector:
                        Provider.of<SourceNotifier>(context).source.selector,
                  ),
                ),
              );
            },
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
              cupertino: (_, __) => Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: CupertinoSlidingSegmentedControl(
                      groupValue: segmentedControlGroupValue,
                      thumbColor: Colors.purple,
                      children: myTabs,
                      onValueChanged: (i) {
                        setState(() {
                          segmentedControlGroupValue = i;
                          _controller.animateTo(i);
                        });
                      }),
                ),
              ),
              material: (_, __) => TabBar(
                indicatorColor: Colors.transparent,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontSize: 17.sp),
                controller: _controller,
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
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,

          children: [
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
                              crossAxisCount: 4,
                            ),
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
            AllComicsPage(),
            Container(
                child: CupertinoButton(
              child: Text("RETRIEVE"),
              onPressed: () {
                debugPrint(Provider.of<SourceNotifier>(context, listen: false)
                    .source
                    .name);
              },
            ))
          ],
        ),
      ),
    );
  }

  simulate() async {
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
