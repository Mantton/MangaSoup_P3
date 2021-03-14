import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/screens/d_library.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/screens/d_queue.dart';

class DownloadsHome extends StatefulWidget {
  @override
  _DownloadsHomeState createState() => _DownloadsHomeState();
}

class _DownloadsHomeState extends State<DownloadsHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Downloads"),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.purple,
            labelStyle: TextStyle(fontSize: 17, fontFamily: "Lato"),
            tabs: [
              Tab(
                text: "Library",
              ),
              Tab(
                text: "Queue",
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () => debugPrint("Search Downloads"),
            )
          ],
        ),
        body: TabBarView(
          children: [
            DownloadLibrary(),
            DownloadQueue(),
          ],
        ),
      ),
    );
  }
}
