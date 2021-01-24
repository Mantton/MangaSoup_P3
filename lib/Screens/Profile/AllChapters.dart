import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Reader/DebugReaders/DebugReader2.dart';
import 'package:provider/provider.dart';

class ChapterList extends StatefulWidget {
  final List chapterList;

  const ChapterList({Key key, @required this.chapterList}) : super(key: key);

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  bool editMode = false;
  List selectedChapters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chapters" + ((editMode) ? " (Edit Mode)" : "")),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                Icons.edit,
                color: (editMode) ? Colors.amber : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  editMode = !editMode;
                });
              })
        ],
      ),
      body: Stack(
        children: widget.chapterList.length != 0
            ? [
                body(),
                editManager(),
              ]
            : [
                Center(
                  child: Text(
                    "No Chapters Available",
                    style: isEmptyFont,
                  ),
                )
              ],
      ),
    );
  }

  Widget editManager() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      bottom: (editMode) ? 0 : -100.h,
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Container(
            // color: Colors.redAccent,
            width: 200,
            child: Row(
              children: [
                CupertinoButton(
                  child: Text('Select'),
                  onPressed: selectMenu, //todo menu
                ),
                Spacer(),
                VerticalDivider(
                  color: Colors.grey,
                  thickness: 2,
                  width: 2,
                  indent: 25,
                  endIndent: 25,
                ),
                Spacer(),
                CupertinoButton(
                  child: Text('Mark'),
                  onPressed: (selectedChapters.length == 0) ? null : markMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectAll() {
    setState(() {
      selectedChapters = widget.chapterList;
    });
    Navigator.pop(context);
  }

  deselectAll() {
    setState(() {
      selectedChapters = [];
    });
    Navigator.pop(context);
  }

  fill() {
    if (selectedChapters.length != 2)
      Navigator.pop(context);
    else {
      int start = widget.chapterList.indexOf(selectedChapters[0]);
      int end = widget.chapterList.indexOf(selectedChapters[1]);
      print("$start, $end");

      if (end < start) {
        setState(() {
          selectedChapters.addAll(widget.chapterList.sublist(end + 1, start));
        });
      } else {
        setState(() {
          selectedChapters.addAll(widget.chapterList.sublist(start + 1, end));
        });
      }

      debugPrint(selectedChapters.toString());
      Navigator.pop(context);
    }
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
                      child: Text("Select All"), onPressed: selectAll),
                  CupertinoActionSheetAction(
                      child: Text("Deselect All"), onPressed: deselectAll),
                  CupertinoActionSheetAction(
                      child: Text("Fill Range (Select Between)"),
                      onPressed: fill),
                ],
              )),
    );
  }

  markAsRead() async {
    Navigator.pop(context);
    showLoadingDialog(context);
    await Provider.of<ComicDetailProvider>(context, listen: false)
        .addBulk(selectedChapters);
    Navigator.pop(context);
  }

  markAsUnread() async {
    Navigator.pop(context);
    showLoadingDialog(context);
    await Provider.of<ComicDetailProvider>(context, listen: false)
        .removeBulk(selectedChapters);
    Navigator.pop(context);
  }

  markMenu() {
    return showPlatformModalSheet(
      context: (context),
      builder: (_) => PlatformWidget(
          material: (_, __) =>
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text("Mark as Read"),
                    onTap: markAsRead,
                  ),
                  ListTile(
                    title: Text("Mark as Unread"),
                    onTap: markAsUnread,
                  ),
                ],
              ),
          cupertino: (_, __) =>
              CupertinoActionSheet(
                title: Text("Mark As"),
                cancelButton: CupertinoButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  CupertinoActionSheetAction(
                      child: Text("Read"), onPressed: markAsRead),
                  CupertinoActionSheetAction(
                      child: Text("Unread"), onPressed: markAsUnread),
                ],
              )),
    );
  }

  Widget body() {
    return Consumer<ComicDetailProvider>(builder: (context, provider, _) {
      List readChapterNames = [];
      List readChapterLinks = [];
      if (provider.history.readChapters != null) {
        readChapterNames =
            provider.history.readChapters.map((m) => m['name']).toList() ?? [];
        readChapterLinks =
            provider.history.readChapters.map((m) => m['link']).toList() ?? [];
      }
      List chapterList = widget.chapterList;
      return Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Container(
          child: ListView.builder(
              itemCount: chapterList.length,
              itemBuilder: (BuildContext context, int index) {
                Chapter chapter = Chapter.fromMap(chapterList[index]);
                return Container(
                  height: 60.h,
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        if (!editMode) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DebugReader2(
                                    chapters: chapterList
                                        .map((e) => Chapter.fromMap(e))
                                        .toList(),
                                    selectedChapter: chapter,
                                    selector:
                                    Provider
                                        .of<ComicHighlightProvider>(context)
                                        .highlight
                                        .selector,
                                  ),
                            ),
                          );
                        } else {
                          if (!selectedChapters.contains(chapterList[index])) {
                            setState(() {
                              selectedChapters.add(chapterList[index]);
                            });
                          } else {
                            setState(() {
                              selectedChapters.remove(chapterList[index]);
                            });
                          }
                        }
                      },
                      title: Text(
                        chapter.name,
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: (readChapterNames.contains(chapter.name) ||
                                  readChapterLinks.contains(chapter.link))
                              ? Colors.grey[700]
                              : Colors.white,
                        ),
                      ),
                      subtitle: (chapter.maker.isNotEmpty)?Text(
                         chapter.maker,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.sp,
                        ),
                      ): null,
                      trailing: Text(
                        chapter.date ?? "",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.sp,
                        ),
                      ),
                      leading: (!editMode)
                          ? null
                          : Icon(
                        (selectedChapters.contains(chapterList[index]))
                            ? Icons.check
                            : Icons.radio_button_unchecked,
                        color:
                        (selectedChapters.contains(chapterList[index]))
                            ? Colors.purple
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
    });
  }
}
