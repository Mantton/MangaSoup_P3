import 'package:flutter/material.dart';

class DownloadQueue extends StatefulWidget {
  @override
  _DownloadQueueState createState() => _DownloadQueueState();
}

class _DownloadQueueState extends State<DownloadQueue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Queue"),
      ),
    );
  }
}
