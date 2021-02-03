import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';

class TransitionPage extends StatelessWidget {
  final ReaderChapter current;
  final ReaderChapter next;

  const TransitionPage({Key key, this.current, this.next}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Transitioning from ${current.chapterName} to ${next.chapterName}",
        ),
      ),
    );
  }
}
