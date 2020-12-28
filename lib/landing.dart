import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Screens/Favorite/FavouriteHome.dart';
import 'package:mangasoup_prototype_3/Screens/More/MoreHomePage.dart';

import 'Downloads/DownloadsHome.dart';
import 'Screens/Explore/Home.dart';
import 'Screens/Recent/RecentsHome.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      body: IndexedStack(
        index: _index,
        children: [
          Container(
            child: Home(), // Explore
          ),
          Container(
            child: FavouritePage(),
          ),
          Container(
            child: HistoryPage(),
          ),
          Container(
            child: Container(),
            //todo, implement IOS flutter_downloads instructions
            // DownloadsPage(),
          ),
          Container(
            child: MorePage(),
          )
        ],
      ),
      bottomNavBar: PlatformNavBar(
        currentIndex: _index,
        backgroundColor: Colors.black,
        itemChanged: (v) {
          setState(() {
            if (v != _index)
              _index = v;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: (_index != 0)
                  ? Icon(Icons.explore_outlined)
                  : Icon(Icons.explore),
              label: "Explore"),
          BottomNavigationBarItem(
              icon:
                  Icon((_index != 1) ? Icons.favorite_border : Icons.favorite),
              label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon((_index != 2)
                  ? Icons.access_time_rounded
                  : Icons.access_time_sharp),
              label: "Recent"),
          BottomNavigationBarItem(
              icon: Icon((_index != 3)
                  ? Icons.download_outlined
                  : Icons.download_sharp),
              label: "Downloads"),
          BottomNavigationBarItem(icon: Icon(Icons.dehaze), label: "More"),
        ],
        material: (_, __) => MaterialNavBarData(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey[700],
          type: BottomNavigationBarType.fixed,
        ),
        cupertino: (_, __) => CupertinoTabBarData(
          activeColor: Colors.purple,
          inactiveColor: Colors.grey,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
