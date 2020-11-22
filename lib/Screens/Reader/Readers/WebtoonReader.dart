import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';

class WebtoonReader extends StatefulWidget {
  @override
  _WebtoonReaderState createState() => _WebtoonReaderState();
}

class _WebtoonReaderState extends State<WebtoonReader> {
  List<ImageChapter> loadedChapters = List();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: loadedChapters
          .map(
            (chapter) => ListView(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: chapter.images
                  .map(
                    (image) => Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              // padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width,
                              child: ReaderImage(
                                link: image,
                                referer: chapter.referer,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
