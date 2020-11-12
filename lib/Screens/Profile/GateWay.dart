import "package:flutter/material.dart";
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Providers/ViewHistoryProvider.dart';
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

    /// Get Profile
    ComicProfile profile = await _manager.getProfile(
      widget.highlight.selector,
      widget.highlight.link,
    );

    /// Initialize Providers
    await Provider.of<ComicHighlightProvider>(context, listen: false)
        .loadHighlight(widget.highlight); // Load Current Highlight to Provider
    await Provider.of<ComicDetailProvider>(context, listen: false)
        .init(widget.highlight); // Initialize Read Chapter History

    /// Save to View History
    // todo, get setting to check whether to save hentai sources comics to history
    bool hentai = widget.highlight.isHentai ?? false;
    if (!hentai) {
      await Provider.of<ViewHistoryProvider>(context, listen: false)
          .addToHistory(widget.highlight); // Add to View History
    }

    return profile;
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
