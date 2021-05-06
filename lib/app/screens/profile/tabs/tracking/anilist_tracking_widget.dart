import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/tracking/tracking_home.dart';
import 'package:mangasoup_prototype_3/app/screens/track/anilist/anilist_home.dart';
import 'package:mangasoup_prototype_3/app/screens/track/anilist/anilist_search_dialog.dart';
import 'package:provider/provider.dart';

class AnilistWidget extends StatefulWidget {
  final ComicHighlight highlight;

  const AnilistWidget({Key key, this.highlight}) : super(key: key);

  @override
  _AnilistWidgetState createState() => _AnilistWidgetState();
}

class _AnilistWidgetState extends State<AnilistWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return Container(
        child: Container(
          child: FutureBuilder(
            future: provider.preferences().then((value) =>
                value.getString(PreferenceKeys.ANILIST_ACCESS_TOKEN)),
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
                            element.trackerType == 3)
                        ? Container(
                            child: EditTrack(
                              tracker: p.comicTrackers.firstWhere((element) =>
                                  element.comicId ==
                                      p.comics
                                          .firstWhere((element) =>
                                              element.link ==
                                              widget.highlight.link)
                                          .id &&
                                  element.trackerType == 3),
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
                                      Image.asset("assets/images/anilist.png"),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "AniList",
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
                                    child: Text(
                                      "Add",
                                      style: notInLibraryFont,
                                    ),
                                    onPressed: () => anilistSearchDialog(
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
                            Image.asset("assets/images/anilist.png"),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "AniList",
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
                              builder: (_) => AnilistHome(),
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
