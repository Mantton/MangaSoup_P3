import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/DiscussionScreen.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/ProfileScreen.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/TrackingScreen.dart';

class ProfilePage extends StatefulWidget {
  final ComicProfile profile;
  final ComicHighlight highlight;

  const ProfilePage({Key key, @required this.profile,@required this.highlight}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>with AutomaticKeepAliveClientMixin {
  ComicProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_profile.title),
          centerTitle: true,
          backgroundColor: Colors.black,
          bottom: TabBar(
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                text: "Details",
              ),
              Tab(
                text: "Discussion",
              ),
              Tab(
                text: "Tracking",
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: TabBarView(
          children: [
            ProfilePageScreen(
              comicProfile: _profile,
              highlight: widget.highlight,
            ),
            DiscussionPage(),
            TrackingPage(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
