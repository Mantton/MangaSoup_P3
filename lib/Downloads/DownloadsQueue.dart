import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Globals.dart';

class QueuePage extends StatefulWidget {
  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Your Queue is Empty!",
          style: isEmptyFont,
        ),
      ),
    );
  }
}
