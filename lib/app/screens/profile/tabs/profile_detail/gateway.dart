import "package:flutter/material.dart";
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/custom_profile.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/generic_profile.dart';
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
    Profile profile = await _manager.getProfile(
      widget.highlight.selector,
      widget.highlight.link,
    );

    Comic generated = Comic(
        title: widget.highlight.title,
        link: widget.highlight.link,
        thumbnail: profile.thumbnail,
        referer: widget.highlight.imageReferer,
        source: widget.highlight.source,
        sourceSelector: widget.highlight.selector,
        chapterCount: profile.chapterCount ?? 0);
    Comic comic = Provider.of<DatabaseProvider>(context, listen: false)
        .isComicSaved(generated);
    if (comic != null) {
      // UPDATE VALUES HERE
      comic.thumbnail = profile.thumbnail;
      comic.updateCount = 0;
      comic.chapterCount = profile.chapterCount ?? 0;
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
            return Center(
              child: LoadingIndicator(),
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
            Profile prof = snapshot.data['profile'];
            int id = snapshot.data['id'];
            if (prof.properties == null) {
              return GenericProfilePage(
                profile: prof,
                comicId: id,
              );
            } else {
              return CustomProfilePage(
                profile: prof,
                comicId: id,
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
