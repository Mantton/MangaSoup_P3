import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/More/MoreHomePage.dart';
import 'package:mangasoup_prototype_3/app/screens/history/history_home.dart';
import 'package:mangasoup_prototype_3/app/screens/library/library_home.dart';
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
            child: LibraryHome(), // Library
          ),
          Container(
            child: HistoryHome(), // View History
          ),
          Container(
            color: Colors.grey[900],
            // push to general discussions page
          ),
          Container(
            child: MorePage(), // More
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: Colors.black,
        onTap: (v) {
          setState(() {
            if (v != _index) _index = v;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey[700],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: (_index != 0)
                ? Icon(CupertinoIcons.compass)
                : Icon(
                    CupertinoIcons.compass_fill,
                  ),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              (_index != 1) ? CupertinoIcons.folder : CupertinoIcons.folder_fill,
            ),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              (_index != 2) ? CupertinoIcons.clock : CupertinoIcons.clock_fill,
            ),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              (_index != 3) ? CupertinoIcons.bubble_left : CupertinoIcons.bubble_left_fill,
            ),
            label: "Discussions",
          ),
          BottomNavigationBarItem(
            icon: Icon((_index != 4)
                ? CupertinoIcons.square_stack_3d_up
                : CupertinoIcons.square_stack_3d_up_fill),
            label: "More",
          ),
        ],
      ),
    );
  }
}
