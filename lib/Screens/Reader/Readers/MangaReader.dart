import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

class MangaReader extends StatefulWidget {
  final int page;

  const MangaReader({Key key, this.page}) : super(key: key);

  @override
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  PreloadPageController _controller;

  @override
  void initState() {
    _controller = PreloadPageController(initialPage: widget.page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      // physics: NeverScrollableScrollPhysics(),
      children: Provider.of<ReaderProvider>(context)
          .loadedChapters
          .map(
            (chapter) => PreloadPageView(
              // physics: NeverScrollableScrollPhysics(),

              preloadPagesCount: 2,
              scrollDirection: Axis.horizontal,
              controller: _controller,
              onPageChanged: (p) {
                Provider.of<ReaderProvider>(context, listen: false).setPage(
                    p + 1);
              },
              children: chapter.images
                  .map(
                    (image) =>
                    Center(
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
