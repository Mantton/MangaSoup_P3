import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Downloads/DownloadsLibrary.dart';
import 'package:mangasoup_prototype_3/Downloads/DownloadsQueue.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  bool allPaused = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: PlatformIconButton(
            onPressed: () {
              setState(() {
                allPaused = !allPaused;
                showMessage(
                    (allPaused) ? "Paused!" : "Started!",
                    (allPaused) ? Icons.pause : Icons.play_arrow,
                    Duration(milliseconds: 1500));
              });
            },
            color: (!allPaused) ? Colors.amber : Colors.green,
            cupertinoIcon: Icon(
              (!allPaused) ? CupertinoIcons.pause : CupertinoIcons.play,
            ),
            materialIcon: Icon(
              (!allPaused) ? Icons.pause : Icons.play_arrow,
            ),
          ),
          title: Text("Downloads"),
          centerTitle: true,
          actions: [
            PlatformIconButton(
              onPressed: () {},
              color: Colors.redAccent,
              cupertinoIcon: Icon(CupertinoIcons.pen),
              materialIcon: Icon(Icons.edit),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.purpleAccent,
            unselectedLabelColor: Colors.grey[900],
            labelStyle: TextStyle(
                fontSize: 15.sp,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold),
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
            DownloadLibraryPage(),
            QueuePage(),
          ],
        ),
      ),
    );
  }
}
