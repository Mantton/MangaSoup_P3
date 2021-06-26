import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/downloads.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/chapter_tile.dart';
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

  void onTap(Chapter chapter, ChapterData data) async {
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
          fullscreenDialog: true,
        ),
      );
    }

    setState(() {});
  }

  List<Chapter> chapters = List();
  bool descending = true;

  @override
  void initState() {
    super.initState();
    chapters = List.of(widget.chapterList);
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
          IconButton(
              onPressed: () {
                setState(() {
                  if (descending) {
                    chapters.sort((a, b) =>
                        a.generatedNumber.compareTo(b.generatedNumber));
                    descending = false;
                  } else {
                    chapters.sort((a, b) =>
                        b.generatedNumber.compareTo(a.generatedNumber));
                    descending = true;
                  }
                });
              },
              icon: Icon(
                descending ? CupertinoIcons.sort_up : CupertinoIcons.sort_down,
                color: Colors.white,
              ))
        ],
      ),
      body: Consumer<DatabaseProvider>(
          builder: (BuildContext context, provider, _) {
        return ListView.builder(
            itemCount: widget.chapterList.length,
            itemBuilder: (BuildContext context, int index) {
              Chapter chapter = chapters[index];
              ChapterData data = provider.checkIfChapterMatch(chapter);
              ChapterDownload downloadInfo;
              bool historyTarget = false;

              if (data != null) {
                downloadInfo = provider.chapterDownloads.firstWhere(
                    (element) => element.chapterId == data.id,
                    orElse: () => null);
                if (widget.history != null)
                  historyTarget = (widget.history.chapterId == data.id);
              }

              bool similarRead =
                  provider.checkSimilarRead(chapter, widget.comicId);

              TextStyle readFont = TextStyle(
                color: similarRead ? Colors.grey[800] : Colors.white,
              );
              // It is Store
              return ListTile(
                title: Text(chapter.name, style: readFont),
                subtitle: chapter.maker.isNotEmpty
                    ? Text(
                        chapter.maker,
                  style: TextStyle(color: Colors.grey[700]),
                      )
                    : null,
                trailing: FittedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Download Info
                      (downloadInfo != null)
                          ? DownloadIcon(
                              status: downloadInfo.status,
                            )
                          : Container(),
                      // History Info
                      historyTarget && data != null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.purple,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  (data.images.length == 0 ||
                                          data.lastPageRead >=
                                              data.images.length)
                                      ? "Read"
                                      : "Page ${data.lastPageRead}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Lato",
                                  ),
                                )
                              ],
                            )
                          : Container(),

                      // Similar Read Info
                      similarRead && data == null
                          ? Text(
                              "Similar Read",
                              style: TextStyle(color: Colors.blueGrey[800]),
                            )
                          : Container(),
                      // Date
                      Text(
                       chapter.date.isNotEmpty ?  chapter.date: " ",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                selectedTileColor: Colors.grey[900],
                selected: isSelected(chapter),
                onLongPress: () => longPress(chapter),
                onTap: () => onTap(chapter, data),
              );
            });
      }),
      bottomSheet: editMode()
          ? Container(
        height: 60,
              color: Colors.grey[900],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      child: Text("Fill"),
                      onPressed: selectMenu,
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      child: Text("Mark"),
                      onPressed: markMenu,
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      child: Text("Manage"),
                      onPressed: downloadMenu,
                    ),
                  ),
                ],
              ),
            )
          : null,
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

  downloadMenu() {
    return showPlatformModalSheet(
      context: (context),
      builder: (_) => PlatformWidget(
        material: (_, __) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("Add to Download Queue"),
              onTap: () async {
                Provider.of<DatabaseProvider>(context, listen: false)
                    .downloadChapters(
                        _selectedChapters,
                        widget.comicId,
                        widget.source,
                        widget.selector,
                        Theme.of(context).platform);

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Remove Download"),
              onTap: () async {
                await deleteDownload().then(
                  (value) => Navigator.pop(context),
                );
                setState(() {
                  _selectedChapters.clear();
                });
              },
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoActionSheet(
          title: Text("Manage Download"),
          cancelButton: CupertinoButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text("Add to Download Queue"),
              onPressed: () async {
                List<Chapter> sending = List.of(_selectedChapters);
                // Sort before sending to download;
                sending.sort(
                    (a, b) => b.generatedNumber.compareTo(a.generatedNumber));
                Provider.of<DatabaseProvider>(context, listen: false)
                    .downloadChapters(sending, widget.comicId, widget.source,
                        widget.selector, Theme.of(context).platform);
                setState(() {
                  _selectedChapters.clear();
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Remove Download"),
              onPressed: () async {
                await deleteDownload().then(
                  (value) => Navigator.pop(context),
                );
                setState(() {
                  _selectedChapters.clear();
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Clear Chapter Data"),
              onPressed: () async {
                showLoadingDialog(context);
                Provider.of<DatabaseProvider>(context, listen: false)
                    .clearChapterDataInfo(_selectedChapters)
                    .then((value) {
                  showSnackBarMessage("Chapter Data Cleared!");

                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  showSnackBarMessage("An error Occurred", error: true);

                  Navigator.pop(context);
                });
                setState(() {
                  _selectedChapters.clear();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future deleteDownload() {
    return showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Delete Downloads"),
        content: Text(
          "Are you sure you want to delete the downloads for the selected "
          "chapters?\nSelected chapters which have not been downloaded "
          "will be ignored.",
        ),
        actions: [
          PlatformDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDefaultAction: true),
          ),
          PlatformDialogAction(
            child: Text("Proceed"),
            onPressed: () {
              Provider.of<DatabaseProvider>(context, listen: false)
                  .deleteDownloads(_selectedChapters);

              Navigator.pop(context);
              setState(() {
                _selectedChapters.clear();
              });
            },
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );
  }
}
