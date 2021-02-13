import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/bookmark.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:provider/provider.dart';

class ComicBookMarksPage extends StatelessWidget {
  final int comicId;
  final Profile profile;

  const ComicBookMarksPage(
      {Key key, @required this.comicId, @required this.profile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      List<BookMark> bookmarks = List.of(provider.bookmarks)
          .where((element) => element.comicId == comicId)
          .toList();
      return Scaffold(
        appBar: AppBar(
          title: Text("Bookmarks"),
          centerTitle: true,
          actions: [
            bookmarks.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.transparent,
                    ),
                    onPressed: () => null,
                  )
                : Container(),
          ],
        ),
        body: bookmarks.isEmpty
            ? Center(
                child: Text(
                  "No Bookmarks",
                  style: notInLibraryFont,
                ),
              )
            : ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(
                    bookmarks[index].chapterName,
                    style: notInLibraryFont,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderHome(
                        selector: profile.selector,
                        chapters: profile.chapters,
                        initialChapterIndex: profile.chapters.indexOf(
                            profile.chapters.firstWhere((element) =>
                                element.link == bookmarks[index].chapterLink)),
                        comicId: comicId,
                        source: profile.source,
                        initialPage: bookmarks[index].page,
                      ),
                    ),
                  ),
                  subtitle: Text("Page ${bookmarks[index].page}"),
                  trailing: IconButton(
                    icon: Icon(
                      CupertinoIcons.clear_circled,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => provider.deleteBookMark(bookmarks[index]),
                  ),
                ),
              ),
      );
    });
  }
}
