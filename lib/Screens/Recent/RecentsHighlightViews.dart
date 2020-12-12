import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/GateWay.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

hGrid(List<ViewHistory> comics) {
  List<ComicHighlight> highlights = comics.map((e) => e.highlight).toList();

  return ComicGrid(
    comics: highlights,
    crossAxisCount: 3,
  );
}

tList(List<ViewHistory> comics) {
  return ListView.builder(
      itemCount: comics.length,
      itemBuilder: (_, int index) {
        ViewHistory comic = comics[index];
        return ListTile(
          title: Text(comic.highlight.title),
          subtitle: Text(comic.highlight.source ?? ""),
          trailing: Text(formatDate(comic.timeViewed)),
        );
      });
}

String formatDate(DateTime tm) {
  DateTime today = DateTime.now();

  Duration difference = today.difference(tm);
  int comicWeekOfYear = ((tm.day - tm.weekday + 10) / 7).floor();
  int todayWeekOfYear = ((today.day - today.weekday + 10) / 7).floor();
  if (difference.inHours < today.hour) {
    return "Today";
  } else if (difference.inHours < 24 + today.hour) {
    return "Yesterday";
  } else if (comicWeekOfYear == todayWeekOfYear) {
    return "Earlier This Week";
  } else if ((comicWeekOfYear - todayWeekOfYear) == 1) {
    return "Last Week";
  } else if ((comicWeekOfYear - todayWeekOfYear) <= 4) {
    return "This month";
  } else if ((comicWeekOfYear - todayWeekOfYear) <= 8) {
    return "Last month";
  } else if (tm.year == today.year) {
    return 'This Year';
  } else
    return "${tm.year}";
}

class HistoryView extends StatefulWidget {
  final List<ViewHistory> comics;
  final int mode;

  const HistoryView({Key key, this.comics, this.mode}) : super(key: key);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    return view(widget.mode, groupDates(widget.comics));
  }

  TextStyle dateFont = TextStyle(
      color: Colors.grey,
      fontSize: 30.h,
      fontWeight: FontWeight.bold,
      fontFamily: "Lato");

  Widget view(int mode, Map<dynamic, List<ViewHistory>> sortedComics) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.w),
        child: layout(
          sortedComics,
          widget.mode,
        ),
      ),
    );
  }

  Map<dynamic, List<ViewHistory>> groupDates(List<ViewHistory> comics) {
    Map sorted = groupBy(comics.reversed.toList(),
        (ViewHistory comic) => formatDate(comic.timeViewed));
    return sorted;
  }

  Widget layout(Map<dynamic, List<ViewHistory>> sorted, int mode) {
    return Container(
      child: Column(
        children: List.generate(sorted.length, (index) {
          var title = sorted.keys.toList()[index];
          List<ViewHistory> comics = sorted[title]; // Init Comics
          comics.sort((a, b) =>
              b.timeViewed.compareTo(a.timeViewed)); // Sort by Time Viewed
          return Container(
            margin: EdgeInsets.only(
              bottom: 20.h,
            ),
            child: stickyHeader(
              (mode == 1)
                  ? ComicGrid(comics: comics.map((e) => e.highlight).toList())
                  : (mode == 2)
                      ? lTile(comics.map((e) => e.highlight).toList())
                      : Container(
                          child: Text("Invalid Layout Selection"),
                        ),
              "$title",
            ),
          );
        }),
      ),
    );
  }

  Widget lTile(List<ComicHighlight> highlights) {
    return ListView.builder(
        itemCount: highlights.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          ComicHighlight comic = highlights[index];
          return Container(
            margin: EdgeInsets.only(bottom: 5.h),
            child: ListTile(
              title: Text(
                comic.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
              subtitle: Text(
                comic.source ?? "",
                style: TextStyle(
                  fontSize: 15.sp,
                ),
              ),
              leading: Image.network(
                highlights[index].thumbnail,
              ),
              onTap: () {
                debugPrint("${comic.title} @ ${comic.link} /f ${comic.source}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileGateWay(comic),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget stickyHeader(Widget content, String header) {
    return StickyHeader(
      header: Container(
        height: 50.0,
        color: Colors.grey[900],
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '$header',
          style: dateFont,
        ),
      ),
      content: content,
    );
  }
}
