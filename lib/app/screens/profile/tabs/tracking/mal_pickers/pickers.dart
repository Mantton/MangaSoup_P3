import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

datePickerDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Date Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => datePickerBuilder(),
  );
}

datePickerBuilder() {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: MangaSoupDatePicker(),
  );
}

class MangaSoupDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Date Picker",
            style: notInLibraryFont,
          ),
          Container(
            height: 200,
            child: PlatformWidget(
              cupertino: (_, __) =>
                  CupertinoDatePicker(onDateTimeChanged: (v) => null),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Spacer(),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Set",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

scorePickerDialog({@required BuildContext context, @required Tracker t}) {
  showGeneralDialog(
    barrierLabel: "Score Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => scorePickerBuilder(t),
  );
}

scorePickerBuilder(Tracker t) {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: MangaSoupScorePicker(
      tracker: t,
    ),
  );
}

class MangaSoupScorePicker extends StatelessWidget {
  final Tracker tracker;

  const MangaSoupScorePicker({Key key, this.tracker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Tracker t = tracker;
    return Consumer<DatabaseProvider>(builder: (context, provider, _) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Score Picker",
              style: notInLibraryFont,
            ),
            Container(
              height: 130,
              child: PlatformWidget(
                cupertino: (_, __) => CupertinoPicker.builder(
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => t.score = i + 1,
                  childCount: 10,
                  itemBuilder: (_, index) => Center(
                    child: Text("${index + 1}"),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    child: Text(
                      "Remove",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: "Lato",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      t.score = null;
                      provider
                          .updateTracker(t)
                          .then(
                              (value) => showSnackBarMessage("Sync Complete!"))
                          .catchError((e) {
                        showSnackBarMessage("An Error Occurred\n$e");
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Spacer(),
                Expanded(
                  child: InkWell(
                    child: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: "Lato",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: InkWell(
                      child: Text(
                        "Set",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        provider
                            .updateTracker(t)
                            .then((value) =>
                                showSnackBarMessage("Sync Complete!"))
                            .catchError((e) {
                          showSnackBarMessage("An Error Occurred\n$e");
                        });
                        Navigator.pop(context);
                      }),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}

statusPickerDialog({@required BuildContext context, @required Tracker t}) {
  showGeneralDialog(
    barrierLabel: "Date Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => statusPickerBuilder(t),
  );
}

statusPickerBuilder(Tracker t) {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Container(
      child: MangaSoupMalStatusPicker(
        tracker: t,
      ),
      height: 450,
    ),
  );
}

class MangaSoupMalStatusPicker extends StatefulWidget {
  final Tracker tracker;

  const MangaSoupMalStatusPicker({Key key, @required this.tracker})
      : super(key: key);

  @override
  _MangaSoupMalStatusPickerState createState() =>
      _MangaSoupMalStatusPickerState();
}

class _MangaSoupMalStatusPickerState extends State<MangaSoupMalStatusPicker> {
  TrackStatus s;

  @override
  void initState() {
    s = widget.tracker.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, provider, _) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                "Status Picker",
                style: notInLibraryFont,
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: TrackStatus.values.length,
                  itemBuilder: (_, index) => CheckboxListTile(
                    title: Text(
                      convertToPresentable(TrackStatus.values[index],
                          widget.tracker.trackerType),
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        s = TrackStatus.values[index];
                      });
                    },
                    value: s == TrackStatus.values[index],
                    checkColor: Colors.purple,
                    activeColor: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Text(
                        "Set",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        Tracker t = widget.tracker;
                        t.status = s;
                        try {
                          provider
                              .updateTracker(t)
                              .then((value) =>
                                  showSnackBarMessage("Sync Complete!"))
                              .catchError((e) {
                            showSnackBarMessage("An Error Occurred\n$e");
                          });
                        } catch (err) {
                          showSnackBarMessage("An Error Occurred\n$err");
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

chapterPickerDialog(
    {@required BuildContext context, @required Tracker tracker}) {
  showGeneralDialog(
    barrierLabel: "Chapter Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => chapterPickerBuilder(tracker),
  );
}

chapterPickerBuilder(Tracker t) {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: ChapterPickerWidget(
      tracker: t,
    ),
  );
}

class ChapterPickerWidget extends StatefulWidget {
  final Tracker tracker;

  const ChapterPickerWidget({Key key, this.tracker}) : super(key: key);

  @override
  _ChapterPickerWidgetState createState() => _ChapterPickerWidgetState();
}

class _ChapterPickerWidgetState extends State<ChapterPickerWidget> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(
        text: widget.tracker.lastChapterRead != null
            ? widget.tracker.lastChapterRead.toString()
            : "0");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                "Number of Chapters Read",
                style: notInLibraryFont,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: TextField(
                        decoration: mangasoupInputDecoration("C's Read"),
                        keyboardType: TextInputType.number,
                        onSubmitted: (v) {},
                        controller: _controller,
                      ),
                      width: 100,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      widget.tracker.totalChapters == 0
                          ? '/-'
                          : "/${widget.tracker.totalChapters}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      child: Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        try {
                          Tracker t = widget.tracker;
                          t.lastChapterRead = null;
                          provider
                              .updateTracker(t)
                              .then((value) =>
                                  showSnackBarMessage("Sync Complete!"))
                              .catchError((e) {
                            showSnackBarMessage("An Error Occurred\n$e");
                          });
                          Navigator.pop(context);
                        } catch (err) {
                          showSnackBarMessage("$err");
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: InkWell(
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Text(
                        "Set",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        try {
                          Tracker t = widget.tracker;
                          t.lastChapterRead = int.parse(_controller.text);
                          provider
                              .updateTracker(t)
                              .then((value) =>
                                  showSnackBarMessage("Sync Complete!"))
                              .catchError((e) {
                            showSnackBarMessage("An Error Occurred\n$e");
                          });
                          Navigator.pop(context);
                        } catch (err) {
                          showSnackBarMessage("$err");
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
