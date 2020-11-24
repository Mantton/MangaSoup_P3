import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:provider/provider.dart';

class WebtoonReader extends StatefulWidget {
  final int initialPage;

  const WebtoonReader({Key key, this.initialPage}) : super(key: key);

  @override
  _WebtoonReaderState createState() => _WebtoonReaderState();
}

class _WebtoonReaderState extends State<WebtoonReader> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: Provider
          .of<ReaderProvider>(context)
          .loadedChapters
          .map(
            (chapter) =>
            ListView(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: chapter.images
                  .map(
                    (image) =>
                    Center(
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: ReaderImage(
                          link: image,
                          referer: chapter.referer,
                          fit: BoxFit.fitWidth,
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
