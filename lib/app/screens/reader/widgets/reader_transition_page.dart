import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';

class TransitionPage extends StatelessWidget {
  final Chapter current;
  final Chapter next;

  const TransitionPage({Key key, this.current, this.next}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Text("Transitioning from ${current.name} to ${next.name}")),
    );
  }
}
