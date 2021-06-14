import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/dialogs/mal_search_dialog.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/tracking/anilist_tracking_widget.dart';
import 'package:mangasoup_prototype_3/app/screens/track/mal/mal_screen.dart';
import 'package:provider/provider.dart';

import 'mal_pickers/pickers.dart';

class TrackingHome extends StatelessWidget {
  final ComicHighlight highlight;

  const TrackingHome({Key key, @required this.highlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          MALTrackingWidget(
            highlight: highlight,
          ),
          AnilistWidget(
            highlight: highlight,
          )
        ],
      ),
    );
  }
}

class MALTrackingWidget extends StatefulWidget {
  final ComicHighlight highlight;

  const MALTrackingWidget({Key key, this.highlight}) : super(key: key);

  @override
  _MALTrackingWidgetState createState() => _MALTrackingWidgetState();
}

class _MALTrackingWidgetState extends State<MALTrackingWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return Container(
        child: Container(
          child: FutureBuilder(
            future: provider
                .preferences()
                .then((value) => value.getString(PreferenceKeys.MAL_AUTH)),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Consumer<DatabaseProvider>(builder: (context, p, _) {
                  return Container(
                    // Check for track object else
                    child: p.comicTrackers.any((element) =>
                            element.comicId ==
                                p.comics
                                    .firstWhere((element) =>
                                        element.link == widget.highlight.link)
                                    .id &&
                            element.trackerType == 2)
                        ? Container(
                            child: EditTrack(
                              tracker: p.comicTrackers.firstWhere((element) =>
                                  element.comicId ==
                                      p.comics
                                          .firstWhere((element) =>
                                              element.link ==
                                              widget.highlight.link)
                                          .id &&
                                  element.trackerType == 2),
                            ),
                          )
                        : Card(
                            color: Colors.grey[900],
                            margin: EdgeInsets.all(7),
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Image.asset("assets/images/mal.png"),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "MyAnimeList",
                                        style: notInLibraryFont,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: CupertinoButton(
                                    child: Text("Add", style: notInLibraryFont),
                                    onPressed: () => malSearchDialog(
                                        context: context,
                                        initialQuery: p.comics
                                            .firstWhere((element) =>
                                                element.link ==
                                                widget.highlight.link)
                                            .title,
                                        comicId: p.comics
                                            .firstWhere((element) =>
                                                element.link ==
                                                widget.highlight.link)
                                            .id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                });
              } else {
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.all(7),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: Row(
                          children: [
                            Image.asset("assets/images/mal.png"),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "MyAnimeList",
                              style: notInLibraryFont,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: CupertinoButton(
                          child: Text("Sign In", style: notInLibraryFont),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MALHome(),
                            ),
                          ).then((value) {
                            setState(() {
                              // rebuild
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      );
    });
  }
}

class EditTrack extends StatelessWidget {
  final Tracker tracker;

  const EditTrack({Key key, this.tracker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle def =
        TextStyle(color: Colors.white, fontSize: 20, fontFamily: "lato");
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.all(7),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset(tracker.trackerType == 2
                      ? "assets/images/mal.png"
                      : "assets/images/anilist.png"),
                ),

                Expanded(
                  flex: 8,
                  child: Text(
                    tracker.title,
                    style: notInLibraryFont,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      showPlatformDialog(
                        context: context,
                        builder: (_) => PlatformAlertDialog(
                          title: Text("Delete Local Tracker"),
                          content: Text(
                            "This would delete the tracker locally.",
                          ),
                          actions: [
                            PlatformDialogAction(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            PlatformDialogAction(
                              cupertino: (_, __) => CupertinoDialogActionData(
                                  isDestructiveAction: true),
                              child: Text("Proceed"),
                              onPressed: () {
                                Provider.of<DatabaseProvider>(context,
                                        listen: false)
                                    .deleteTracker(tracker)
                                    .then((value) => Navigator.pop(context));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey[700],
            thickness: 2,
            height: 10,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () =>
                        statusPickerDialog(context: context, t: tracker),
                    child: Text(
                      convertToPresentable(tracker.status, tracker.trackerType),
                      style: def,
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[700],
                    thickness: 5,
                  ),
                  MaterialButton(
                      onPressed: () => chapterPickerDialog(
                          context: context, tracker: tracker),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: tracker.lastChapterRead == null
                                    ? '-'
                                    : "${tracker.lastChapterRead}",
                                style: def),
                            TextSpan(
                              text: tracker.totalChapters == 0
                                  ? '/-'
                                  : "/${tracker.totalChapters}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      )),
                  VerticalDivider(
                    color: Colors.grey[700],
                    thickness: 2,
                  ),
                  MaterialButton(
                    onPressed: () =>
                        scorePickerDialog(context: context, t: tracker),
                    child: Text(
                      tracker.score != null ? "${tracker.score}/10" : "-/10",
                      style: def,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Divider(
          //   color: Colors.grey[700],
          //   thickness: 2,
          //   height: 10,
          // ),
          // buildDate(context, def)
        ]),
      ),
    );
  }

  Row buildDate(BuildContext context, TextStyle def) {
    return Row(
      children: [
        Spacer(),
        MaterialButton(
          onPressed: () => datePickerDialog(context: context),
          child: Text(
            (tracker.dateStarted != null
                    ? "${DateFormat('yyyy-MM-dd').format(tracker.dateStarted)}"
                    : "-") +
                "\nStart Date",
            textAlign: TextAlign.center,
            style: def,
          ),
        ),
        Spacer(),
        MaterialButton(
          onPressed: () => datePickerDialog(context: context),
          child: Text(
            (tracker.dateEnded != null
                    ? "${DateFormat('yyyy-MM-dd').format(tracker.dateEnded)}"
                    : "-") +
                "\nEnd Date",
            textAlign: TextAlign.center,
            style: def,
          ),
        ),
        Spacer(),
      ],
    );
  }
}
