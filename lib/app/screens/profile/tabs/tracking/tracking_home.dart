import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/track/mal/mal_screen.dart';
import 'package:provider/provider.dart';

class TrackingHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        MALTrackingWidget(),
      ],
    ));
  }
}

class MALTrackingWidget extends StatelessWidget {
  final int comicId;

  const MALTrackingWidget({Key key, this.comicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return Container(
        padding: EdgeInsets.all(7),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(15, 15, 15, 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Container(
              child: provider.preferences().then((value) =>
                          value.getString(PreferenceKeys.MAL_AUTH)) !=
                      null
                  ? Container(
                      // Check for track object else
                      child: Provider.of<DatabaseProvider>(context)
                              .comicTrackers
                              .any((element) =>
                                  element.comicId == comicId &&
                                  element.trackerType == 2)
                          ? Container(
                              child: EditTrack(
                                tracker: Provider.of<DatabaseProvider>(context)
                                    .comicTrackers
                                    .firstWhere((element) =>
                                        element.comicId == comicId &&
                                        element.trackerType == 2),
                              ),
                            )
                          : Center(
                              child: CupertinoButton(
                                child: Text("Add"),
                                onPressed: null,
                              ),
                            ),
                    )
                  : Container(
                      child: Center(
                        child: CupertinoButton(
                          child: Text("Sign In"),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MALHome(),
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          ],
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
    return Container();
  }
}
