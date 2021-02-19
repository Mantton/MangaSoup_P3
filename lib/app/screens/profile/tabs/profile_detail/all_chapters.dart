import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:provider/provider.dart';

class ChapterList extends StatefulWidget {
  final List<Chapter> chapterList;
  final int comicId;
  final String source;
  final String selector;
  final Profile profile;
  final History history;

  const ChapterList(
      {Key key,
      this.chapterList,
      this.comicId,
      this.source,
      this.selector,
      this.history,
      this.profile})
      : super(key: key);

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  List<Chapter> _selectedChapters = List();

  bool editMode() => _selectedChapters.isNotEmpty;

  bool isSelected(Chapter chapter) => _selectedChapters.contains(chapter);

  void longPress(Chapter chapter) {
    // Enable Edit mode
    setState(() {
      if (editMode())
        return null;
      else {
        _selectedChapters.add(chapter);
      }
    });
  }

  Future<void> onTap(Chapter chapter, ChapterData data) async {
    // toggle chapter selection
    if (editMode()) {
      if (_selectedChapters.contains(chapter))
        _selectedChapters.remove(chapter);
      else
        _selectedChapters.add(chapter);
    } else {
      // create history, then push
      await Provider.of<DatabaseProvider>(context, listen: false).historyLogic(
          chapter, widget.comicId, widget.source, widget.selector);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderHome(
            selector: widget.selector,
            chapters: widget.chapterList,
            initialChapterIndex: widget.chapterList.indexOf(chapter),
            comicId: widget.comicId,
            source: widget.source,
            initialPage: data != null ? data.lastPageRead : 1,
          ),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chapters",
          style: notInLibraryFont,
        ),
        centerTitle: true,
        actions: [
          (_selectedChapters.length > 0)
              ? Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Row(
                    children: [
                      Text(
                        "${_selectedChapters.length}",
                        textAlign: TextAlign.center,
                        style: notInLibraryFont,
                      ),
                      Icon(Icons.library_books)
                    ],
                  ),
                )
              : Container(),
        ],
      ),
      body: Consumer<DatabaseProvider>(
          builder: (BuildContext context, provider, _) {
        return ListView.builder(
            itemCount: widget.chapterList.length,
            itemBuilder: (BuildContext context, int index) {
              Chapter chapter = widget.chapterList[index];
              ChapterData data = provider.checkIfChapterMatch(chapter);
              bool similarRead =
                  provider.checkSimilarRead(chapter, widget.comicId);
              bool historyTarget = false;
              if (data != null) {
                if (widget.history != null)
                  historyTarget = (widget.history.chapterId == data.id);
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
                  selected: isSelected(chapter),
                  onLongPress: () => longPress(chapter),
                  onTap: () => onTap(chapter, data),
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
                  selected: isSelected(chapter),
                  onLongPress: () => longPress(chapter),
                  onTap: () => onTap(chapter, data),
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
                  subtitle:
                      chapter.maker.isNotEmpty ? Text(chapter.maker) : null,
                  trailing: historyTarget
                      ? fittedBox(data)
                      : Text(
                          chapter.date,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                  selectedTileColor: Colors.grey[900],
                  selected: isSelected(chapter),
                  onLongPress: () => longPress(chapter),
                  onTap: () => onTap(chapter, data),
                );
              }
            });
      }),
      bottomSheet: editMode()
          ? Container(
              height: 50,
              color: Colors.grey[900],
              child: Row(
                children: [
                  Spacer(),
                  CupertinoButton(child: Text("Fill"), onPressed: selectMenu),
                  Spacer(),
                  CupertinoButton(child: Text("Mark"), onPressed: markMenu),
                  Spacer(),
                ],
              ),
            )
          : null,
    );
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

  selectMenu() {
    return showPlatformModalSheet(
      context: (context),
      builder: (_) => PlatformWidget(
        material: (_, __) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("Select All"),
              onTap: selectAll,
            ),
            ListTile(
              title: Text("Deselect All"),
              onTap: deselectAll,
            ),
            ListTile(
              title: Text("Fill Range (Select Between)"),
              onTap: fill,
            )
          ],
        ),
        cupertino: (_, __) => CupertinoActionSheet(
          title: Text("Select"),
          cancelButton: CupertinoButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text("Select All"),
              onPressed: selectAll,
            ),
            CupertinoActionSheetAction(
              child: Text("Deselect All"),
              onPressed: deselectAll,
            ),
            CupertinoActionSheetAction(
              child: Text("Fill Range (Select Between)"),
              onPressed: fill,
            ),
          ],
        ),
      ),
    );
  }

  fill() {
    if (_selectedChapters.length != 2)
      Navigator.pop(context);
    else {
      int start = widget.chapterList.indexOf(_selectedChapters[0]);
      int end = widget.chapterList.indexOf(_selectedChapters[1]);

      if (end < start) {
        setState(() {
          _selectedChapters.addAll(widget.chapterList.sublist(end + 1, start));
        });
      } else {
        setState(() {
          _selectedChapters.addAll(widget.chapterList.sublist(start + 1, end));
        });
      }

      debugPrint(_selectedChapters.toString());
      Navigator.pop(context);
    }
  }

  selectAll() {
    setState(() {
      _selectedChapters = List.of(widget.chapterList);
    });
    Navigator.pop(context);
  }

  deselectAll() {
    setState(() {
      _selectedChapters = [];
    });
    Navigator.pop(context);
  }

  markMenu() {
    return showPlatformModalSheet(
      context: (context),
      builder: (_) => PlatformWidget(
        material: (_, __) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("Mark as Read"),
              onTap: () async {
                await markAsRead();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Mark as Unread"),
              onTap: () async {
                await markAsUnread();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoActionSheet(
          title: Text("Mark As"),
          cancelButton: CupertinoButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text("Read"),
              onPressed: () async {
                await markAsRead();
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Unread"),
              onPressed: () async {
                await markAsUnread();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  markAsRead() async {
    showLoadingDialog(context);
    print(_selectedChapters.length);
    await Provider.of<DatabaseProvider>(context, listen: false).updateFromACS(
        _selectedChapters,
        widget.comicId,
        true,
        widget.source,
        widget.selector);
    setState(() {
      _selectedChapters.clear();
    });
    Navigator.pop(context);
  }

  markAsUnread() async {
    showLoadingDialog(context);
    await Provider.of<DatabaseProvider>(context, listen: false).updateFromACS(
        _selectedChapters,
        widget.comicId,
        false,
        widget.source,
        widget.selector);
    setState(() {
      _selectedChapters.clear();
    });
    Navigator.pop(context);
  }
}
