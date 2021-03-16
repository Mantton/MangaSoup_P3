import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/all_chapters.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/chapter_tile.dart';
import 'package:provider/provider.dart';

class ProfileContentPreview extends StatefulWidget {
  final Profile profile;
  final int comicId;
  final History history;

  const ProfileContentPreview(
      {Key key, @required this.profile, this.comicId, this.history})
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
              left: 10,
              right: 10,
            ),
            child: Row(
              children: [
                Text(
                  "Chapters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[900],
            indent: 10,
            endIndent: 10,
            height: 10.0,
          ),
          containsChapters(),
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
                  Chapter chapter = List.of(widget.profile.chapters)[index];
                  ChapterData data = provider.checkIfChapterMatch(chapter);
                  bool similarRead =
                      provider.checkSimilarRead(chapter, widget.comicId);
                  return ChapterTile(
                    comicID: widget.comicId,
                    profile: widget.profile,
                    data: data,
                    similarRead: similarRead,
                    chapter: chapter,
                    history: widget.history,
                  );
                }),
          ),
          Divider(
            color: Colors.grey[900],
            indent: 10,
            endIndent: 10,
            height: 10.0,
          ),
          SizedBox(
            height: 10,
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
                    profile: widget.profile,
                    history: widget.history,
                  ),
                ),
              );
            },
            child: widget.profile.chapterCount != 0
                ? Container(
              margin: EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 45,
                    child: Center(
                      child: Text(
                        'View all Chapters',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.purple, fontSize: 20),
                      ),
                    ),
                  )
                : Container(
              margin: EdgeInsets.all(15),
                    color: Colors.grey[800],
                    child: ListTile(
                      title: Text(
                        widget.profile.source.toLowerCase() != "mangadex"
                            ? 'No available chapters'
                            : "No Available Chapters for your specified Content Language(s)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    });
  }

  displayChapters(int length) {
    if (length > 5)
      return 5;
    else
      return length;
  }
}
