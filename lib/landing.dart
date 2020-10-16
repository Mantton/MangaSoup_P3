import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/Favorite/FavouriteHome.dart';
import 'Screens/Explore/Home.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            color: Colors.blue,
          ),
          Container(
            color: Colors.grey,
          ),
          Container(
            color: Colors.black,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey[700],
        type: BottomNavigationBarType.fixed,
        onTap: (v) {
          setState(() {
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
      ),
    );
  }
}
