import "package:flutter/material.dart";
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ComicProfile.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/CustomProfile.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:provider/provider.dart';

class ProfileGateWay extends StatefulWidget {
  final ComicHighlight highlight;

  ProfileGateWay(this.highlight);

  @override
  _ProfileGateWayState createState() => _ProfileGateWayState();
}

class _ProfileGateWayState extends State<ProfileGateWay> {
  Future<ComicProfile> _profile;

  Future<ComicProfile> getProfile() async {
    ApiManager _manager = ApiManager();
    return await _manager.getProfile(
      widget.highlight.selector,
      widget.highlight.link,
    );
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
            ComicProfile prof = snapshot.data;
            if (prof.properties == null) {

              return ProfilePage(
                profile: prof,
                highlight: widget.highlight,
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
