import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/DiscussionScreen.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/ProfileScreen.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/ProfileScreens/TrackingScreen.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_screen.dart';

class ProfilePage extends StatefulWidget {
  final ComicProfile profile;
  final int comicId;

  const ProfilePage({Key key, @required this.profile,@required this.comicId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.profile.title),
          centerTitle: true,
          backgroundColor: Colors.black,
          bottom: TabBar(
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 17),
            unselectedLabelStyle:
            TextStyle(fontSize: 17, color: Colors.grey[900]),
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
            NewProfileScreen(
              profile: widget.profile,
              comicId: widget.comicId,
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
