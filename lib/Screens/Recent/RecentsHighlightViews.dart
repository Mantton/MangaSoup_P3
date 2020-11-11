import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:collection/collection.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Duration oneDay = Duration(days: 1);
  Duration twoDay = Duration(days: 2);
  Duration oneWeek = Duration(days: 7);
  String month;
  switch (tm.month) {
    case 1:
      month = "January";
      break;
    case 2:
      month = "February";
      break;
    case 3:
      month = "March";
      break;
    case 4:
      month = "April";
      break;
    case 5:
      month = "May";
      break;
    case 6:
      month = "June";
      break;
    case 7:
      month = "July";
      break;
    case 8:
      month = "August";
      break;
    case 9:
      month = "September";
      break;
    case 10:
      month = "October";
      break;
    case 11:
      month = "November";
      break;
    case 12:
      month = "December";
      break;
  }

  Duration difference = today.difference(tm);

  if (difference.compareTo(oneDay) < 1) {
    return "Today";
  } else if (difference.compareTo(twoDay) < 1) {
    return "Yesterday";
  } else if (difference.compareTo(oneWeek) < 1) {
    switch (tm.weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
    }
  } else if (tm.year == today.year) {
    return '${tm.day} $month';
  } else {
    return '${tm.day} $month ${tm.year}';
  }
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
    fontFamily: "Lato"
  );
  Widget view(int mode, Map<dynamic, List<ViewHistory>> sortedComics) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.w),
        child: (mode == 1)
            ? highlightGrid(sortedComics) // Highlight Grid
            // : (mode == 2)
            //     ? tList(comics) // List View
            : Container(
                color: Colors.lime,
              ),
      ),
    );
  }

  Map<dynamic, List<ViewHistory>> groupDates(List<ViewHistory> comics) {
    Map sorted =
        groupBy(comics, (ViewHistory comic) => formatDate(comic.timeViewed));
    return sorted;
  }

  Widget highlightGrid(Map<dynamic, List<ViewHistory>> sorted) {
    return Container(
      child: Column(
        children: List.generate(sorted.length, (index) {
          var title = sorted.keys.toList()[index];
          List<ViewHistory> comics = sorted[title]; // Init Comics
          comics.sort((a, b) =>
              b.timeViewed.compareTo(a.timeViewed)); // Sort by Time Viewed
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(sorted.keys.toList()[index], style: dateFont,),
              ComicGrid(comics: comics.map((e) => e.highlight).toList())
            ],
          );
        }),
      ),
    );
  }
}
