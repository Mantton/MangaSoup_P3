import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Globals.dart';

class DownloadLibraryPage extends StatefulWidget {
  @override
  _DownloadLibraryPageState createState() => _DownloadLibraryPageState();
}

class _DownloadLibraryPageState extends State<DownloadLibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "You have no comics downloaded",
          style: isEmptyFont,
        ),
      ),
    );
  }
}
