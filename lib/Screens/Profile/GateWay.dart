import "package:flutter/material.dart";
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Providers/ViewHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ComicProfile.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/CustomProfile.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

class ProfileGateWay extends StatefulWidget {
  final ComicHighlight highlight;

  ProfileGateWay(this.highlight);

  @override
  _ProfileGateWayState createState() => _ProfileGateWayState();
}

class _ProfileGateWayState extends State<ProfileGateWay> {
  Future<Map<String, dynamic>> _profile;

  Future<Map<String, dynamic>> getProfile() async {
    ApiManager _manager = ApiManager();

    /// Get Profile
    ComicProfile profile = await _manager.getProfile(
      widget.highlight.selector,
      widget.highlight.link,
    );

    Comic generated = Comic(
        title: widget.highlight.title,
        link: widget.highlight.link,
        thumbnail: widget.highlight.thumbnail,
        referer: widget.highlight.imageReferer,
        source: widget.highlight.source,
        sourceSelector: widget.highlight.selector,
        chapterCount: profile.chapterCount);
    Comic comic =  Provider.of<DatabaseProvider>(context, listen: false)
        .isComicSaved(generated);

    if (comic!= null){
      // UPDATE VALUES HERE
      comic.thumbnail = widget.highlight.thumbnail;
      comic.updateCount = profile.chapterCount - comic.updateCount;
      comic.chapterCount = profile.chapterCount;
    } else
        comic = generated;
    // Evaluate
    int _id = await Provider.of<DatabaseProvider>(context, listen: false)
        .evaluate(comic);

    return {"profile": profile, "id": _id};
  }

  @override
  void initState() {
    super.initState();
    _profile = getProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _profile,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: LoadingIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: InkWell(
                  child: Text(
                    "An Error Occurred\n ${snapshot.error.toString()}\n Tap to go back home",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            ComicProfile prof = snapshot.data['profile'];
            int id = snapshot.data['id'];
            if (prof.properties == null) {
              return ProfilePage(
                profile: prof,
                comicId: id,
              );
            } else {
              return CustomProfilePage(
                profile: prof,
              );
            }
          } else {
            return Scaffold(
              body: Center(
                child: Text("Oops you aren't meant to see this :/"),
              ),
            );
          }
        });
  }
}
