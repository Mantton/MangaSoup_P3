import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';

class TransitionPage extends StatelessWidget {
  final ReaderChapter current;
  final ReaderChapter next;

  const TransitionPage({Key key, this.current, this.next}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RichText(
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
              ),
            ]),
          ),
          (next.generatedNumber - current.generatedNumber > 1)
              ? Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.amber,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: AutoSizeText(
                          "MangaSoup detected missing chapters.\n"
                          "Ch.${current.generatedNumber} → Ch.${next.generatedNumber} jump is greater than 1.",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
            ),
          )
              : Container(),
        ]),
      ),
    );
  }
}
