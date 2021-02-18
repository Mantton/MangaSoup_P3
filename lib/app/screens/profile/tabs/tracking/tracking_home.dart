import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/dialogs/mal_search_dialog.dart';
import 'package:mangasoup_prototype_3/app/screens/track/mal/mal_screen.dart';
import 'package:provider/provider.dart';

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
        ],
      ),
    );
  }
}

class MALTrackingWidget extends StatelessWidget {
  final ComicHighlight highlight;

  const MALTrackingWidget({Key key, this.highlight}) : super(key: key);

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
                                        element.link == highlight.link)
                                    .id &&
                            element.trackerType == 2)
                        ? Container(
                            child: EditTrack(
                              tracker: p.comicTrackers.firstWhere((element) =>
                                  element.comicId ==
                                      p.comics
                                          .firstWhere((element) =>
                                              element.link == highlight.link)
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
                                    child: Text("Add"),
                                    onPressed: () => malSearchDialog(
                                        context: context,
                                        initialQuery: p.comics
                                            .firstWhere((element) =>
                                                element.link == highlight.link)
                                            .title,
                                        comicId: p.comics
                                            .firstWhere((element) =>
                                                element.link == highlight.link)
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
                          child: Text("Sign In"),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MALHome(),
                            ),
                          ).then((value) {}),
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
                Image.asset("assets/images/mal.png"),
                SizedBox(
                  width: 5,
                ),
                Text(
                  tracker.title,
                  style: notInLibraryFont,
                ),
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
                    onPressed: () => print("status"),
                    child: Text(
                      convertToPresentatble(tracker.status),
                      style: def,
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[700],
                    thickness: 5,
                  ),
                  MaterialButton(
                      onPressed: () => print("last read"),
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
                    onPressed: () => print("score"),
                    child: Text(
                      tracker.score != null ? "${tracker.score}" : "-",
                      style: def,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.grey[700],
            thickness: 2,
            height: 10,
          ),
          Row(
            children: [
              Spacer(),
              Text(
                tracker.dateStarted != null
                    ? "${DateFormat('yyyy-MM-dd').format(tracker.dateStarted)}"
                    : "-",
                style: def,
              ),
              Spacer(),
              Text(
                tracker.dateEnded != null
                    ? "${DateFormat('yyyy-MM-dd').format(tracker.dateEnded)}"
                    : "-",
                style: def,
              ),
              Spacer(),
            ],
          )
        ]),
      ),
    );
  }
}
