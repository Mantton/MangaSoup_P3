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
            tabs: [
              Tab(
                text: "Library",
              ),
              Tab(
                text: "Queue",
              )
            ],
          ),
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
