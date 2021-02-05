
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';

class TransitionPage extends StatelessWidget {
  final ReaderChapter current;
  final ReaderChapter next;

  const TransitionPage({Key key, this.current, this.next}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: "Completed: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "roboto",
                fontSize: 25,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: "Chapter ${current.generatedNumber}\n",
              style: TextStyle(
                fontFamily: "roboto",
                fontSize: 25,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: "Next: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "roboto",
                fontSize: 25,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: "Chapter ${next.generatedNumber}\n",
              style: TextStyle(
                fontFamily: "roboto",
                fontSize: 25,
                color: Colors.grey[700],
              ),
            )
          ]),
        ),
      ),
    );
  }
}