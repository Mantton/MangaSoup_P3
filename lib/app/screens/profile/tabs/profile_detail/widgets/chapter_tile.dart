import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';

import '../../../../reader/reader_home.dart';

class ChapterTile extends StatelessWidget {
  final History history;
  final ChapterData data;
  final bool similarRead;
  final Chapter chapter;
  final Profile profile;
  final int comicID;
  final bool selected;
  final Function longPress;
  final Function onTileTap;

  const ChapterTile(
      {Key key,
      this.history,
      this.data,
      this.similarRead,
      this.chapter,
      this.profile,
      this.comicID,
      this.selected = false,
      this.longPress,
      this.onTileTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool historyTarget = false;
    if (data != null) {
      if (history != null) historyTarget = (history.chapterId == data.id);
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
        trailing: historyTarget
            ? fittedBox(data)
            : Text(
                chapter.date,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
        selectedTileColor: Colors.grey[900],
        selected: selected,
        onTap: () => onTap(chapter, data, context),
      );
    }
    if (similarRead) {
      return ListTile(
        leading: historyTarget
            ? Icon(
                Icons.play_arrow,
                color: Colors.purple,
              )
            : null,
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
        trailing: historyTarget
            ? fittedBox(data)
            : Text(
                "SR",
                style: TextStyle(color: Colors.blueGrey[800]),
              ),
        selectedTileColor: Colors.grey[900],
        selected: selected,
        onTap: () => onTap(chapter, data, context),
      );
    } else {
      return ListTile(
        leading: historyTarget
            ? Icon(
                Icons.play_arrow,
                color: Colors.purple,
              )
            : null,
        title: Text(
          chapter.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: chapter.maker.isNotEmpty ? Text(chapter.maker) : null,
        trailing: historyTarget
            ? fittedBox(data)
            : Text(
                chapter.date,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
        selectedTileColor: Colors.grey[900],
        onTap: () => onTap(chapter, data, context),
      );
    }
  }

  FittedBox fittedBox(ChapterData data) {
    return FittedBox(
      child: Row(
        children: [
          Icon(
            Icons.play_arrow,
            color: Colors.purple,
          ),
          SizedBox(
            width: 2,
          ),
          Text(
            "Page ${data.lastPageRead}",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: "Lato",
            ),
          )
        ],
      ),
    );
  }

  onTap(Chapter chapter, ChapterData data, BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderHome(
          selector: profile.selector,
          chapters: profile.chapters,
          initialChapterIndex: profile.chapters.indexOf(chapter),
          comicId: comicID,
          source: profile.source,
          initialPage: data != null ? data.lastPageRead : 1,
        ),
      ),
    );
  }
}
