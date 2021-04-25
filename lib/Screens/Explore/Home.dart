import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/FullBrowse/BrosweHome.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/Search.dart';
import 'package:mangasoup_prototype_3/Screens/Explore/AllComics.dart';
import 'package:mangasoup_prototype_3/Screens/Explore/ForYou.dart';
import 'package:mangasoup_prototype_3/Screens/Explore/LatestComics.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Screens/Tags/AllTags.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<Source> sources = [];
  int _index = 0;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("For You"),
    1: Text("Home"),
    2: Text("Latest"),
  };
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(450, 747.5),
        builder: () {
          return DefaultTabController(
            length: 3,
            initialIndex: 0,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(CupertinoIcons.cloud),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SourcesPage(
                          selector: Provider.of<SourceNotifier>(context)
                              .source
                              .selector,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                title: Text(
                  "Discover",
                  style: notInLibraryFont,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      icon: Icon(CupertinoIcons.tag),
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllTagsPage(),
                              maintainState: true,
                            ),
                          )),
                  IconButton(
                    icon: Icon(CupertinoIcons.collections),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrowsePage(),
                        maintainState: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.search),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchPage(),
                        maintainState: true,
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(45),
                  child: PlatformWidget(
                    cupertino: (_, __) => Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CupertinoSlidingSegmentedControl(
                            groupValue: _index,
                            thumbColor: Colors.purple,
                            children: myTabs,
                            onValueChanged: (i) {
                              setState(() {
                                _index = i;
                                _controller.animateTo(i);
                              });
                            }),
                      ),
                    ),
                    material: (_, __) => TabBar(
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.purple,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontSize: 17),
                      controller: _controller,
                      onTap: (value) {
                        setState(() {
                          _index = value;
                        });
                      },
                      isScrollable: false,
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
                controller: _controller,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ForYouPage(),
                  AllComicsPage(),
                  LatestPage(),
                ],
              ),
            ),
          );
        });
  }
}
