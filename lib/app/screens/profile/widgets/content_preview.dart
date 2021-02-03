import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/book.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/all_chapters.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:provider/provider.dart';

class ProfileContentPreview extends StatefulWidget {
  final Profile profile;
  final int comicId;

  const ProfileContentPreview({Key key, @required this.profile, this.comicId})
      : super(key: key);
  @override
  _ProfileContentPreviewState createState() => _ProfileContentPreviewState();
}

class _ProfileContentPreviewState extends State<ProfileContentPreview> {
  @override
  Widget build(BuildContext context) {
    return contentPreview();
  }

  Widget contentPreview() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 10.w,
              right: 10.w,
            ),
            child: Row(
              children: [
                Text(
                  (!widget.profile.containsBooks) ? "Chapters" : "Books",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                  ),
                ),
                Spacer(),
                !widget.profile.containsBooks
                    ? IconButton(
                        onPressed: () {
                          showSnackBarMessage("Downloads have been disabled.");
                        },
                        icon: Icon(
                          CupertinoIcons.cloud_download,
                          size: 30.w,
                          color: Colors.purple,
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          Divider(
            color: Colors.grey[900],
            indent: 10.w,
            endIndent: 10.w,
            height: 10.0.h,
          ),
          (!widget.profile.containsBooks) ? containsChapters() : containsBooks()
        ],
      ),
    );
  }

  Widget containsChapters() {
    return Consumer<DatabaseProvider>(builder: (context, provider, _) {
      return Column(
        children: [
          Container(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: displayChapters(widget.profile.chapterCount),
                itemBuilder: (BuildContext context, int index) {
                  Chapter chapter = widget.profile.chapters[index];
                  ChapterData data = provider.checkIfChapterMatch(chapter);
                  bool similarRead =
                      provider.checkSimilarRead(chapter, widget.comicId);
                  if (data != null) {
                    TextStyle readFont = TextStyle(
                      color: data.read ? Colors.grey[800] : Colors.white,
                    );
                    // It is Store
                    return ListTile(
                      title: Text(chapter.name, style: readFont),
                      subtitle: chapter.maker.isNotEmpty
                          ? Text(
                              chapter.maker,
                              style: readFont,
                            )
                          : null,
                      trailing: Text(
                        chapter.date,
                        style: readFont,
                      ),
                      selectedTileColor: Colors.grey[900],
                      onTap: () => onTap(chapter),
                    );
                  }
                  if (similarRead) {
                    return ListTile(
                      title: Text(
                        chapter.name,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      subtitle: chapter.maker.isNotEmpty
                          ? Text(
                              chapter.maker,
                              style: TextStyle(color: Colors.grey[800]),
                            )
                          : null,
                      trailing: Text(
                        "SR",
                        style: TextStyle(color: Colors.blueGrey[800]),
                      ),
                      selectedTileColor: Colors.grey[900],
                      onTap: () => onTap(chapter),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        chapter.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle:
                          chapter.maker.isNotEmpty ? Text(chapter.maker) : null,
                      trailing: Text(chapter.date),
                      selectedTileColor: Colors.grey[900],
                      onTap: () => onTap(chapter),
                    );
                  }
                }),
          ),
          Divider(
            color: Colors.grey[900],
            indent: 10.w,
            endIndent: 10.w,
            height: 10.0.h,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterList(
                    chapterList: widget.profile.chapters,
                    comicId: widget.comicId,
                    selector: widget.profile.selector,
                    source: widget.profile.source,
                  ),
                ),
              );
            },
            child: widget.profile.chapterCount != 0
                ? Container(
                    margin: EdgeInsets.only(left: 20.w, right: 20.w),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10)),
                    height: 45.h,
                    child: Center(
                      child: Text(
                        'View all Chapters',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.purple, fontSize: 20.sp),
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.all(15.w),
                    color: Colors.grey[800],
                    child: ListTile(
                      title: Text(
                        widget.profile.source.toLowerCase() != "mangadex"
                            ? 'No available chapters'
                            : "No Available Chapters for your specified Content Language(s)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  onTap(Chapter chapter) async {
    // print("${widget.comicId}, ${widget.profile.source},${widget.profile.selector}, ${chapter.name}, ${chapter.generatedNumber}");
    // print("${widget.profile.chapters.indexOf(chapter)}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderHome(
          selector: widget.profile.selector,
          chapters: widget.profile.chapters,
          initialChapterIndex: widget.profile.chapters.indexOf(chapter),
          comicId: widget.comicId,
          source: widget.profile.source,
        ),
      ),
    );
  }

  Widget containsBooks() {
    return Column(
      children: [
        Container(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: displayChapters(widget.profile.bookCount),
              itemBuilder: (BuildContext context, int index) {
                Book book = widget.profile.books[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterList(
                          chapterList: book.chapters,
                          comicId: widget.comicId,
                          selector: widget.profile.selector,
                          source: widget.profile.source,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50.h,
                    child: ListTile(
                      title: Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 17.sp,
                        ),
                      ),
                      trailing: Text(
                        book.range ?? "",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  displayChapters(int length) {
    if (length > 5)
      return 5;
    else
      return length;
  }
}
