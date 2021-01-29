import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/book.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/all_chapters.dart';
import 'package:mangasoup_prototype_3/app/util/generateChapterNumber.dart';

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
    return Column(
      children: [
        Container(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: displayChapters(widget.profile.chapterCount),
              itemBuilder: (BuildContext context, int index) {
                Chapter chapter = widget.profile.chapters[index];
                double generatedChapterNumber = ChapterRecognition()
                    .parseChapterNumber(chapter.name, widget.profile.title);

                return GestureDetector(
                  onTap: () {
                    // todo, add to db, push to reader
                  },
                  child: Container(
                    height: 55.h,
                    child: Center(
                      child: ListTile(
                        title: Text(
                          chapter.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: (true) ? Colors.grey[700] : Colors.white,
                          ),
                        ),
                        subtitle: chapter.maker.isNotEmpty
                            ? Text(
                                chapter.maker,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.grey[700],
                                ),
                              )
                            : null,
                        trailing: Text(
                          chapter.date ?? "",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
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
