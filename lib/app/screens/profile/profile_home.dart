import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/discussion/discussion_home.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/gateway.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/tracking/tracking_home.dart';

class ProfileHome extends StatefulWidget {
  final ComicHighlight highlight;

  const ProfileHome({Key key, this.highlight}) : super(key: key);
  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "${widget.highlight.title}",
              style: notInLibraryFont,
            ),
            bottom: TabBar(
              indicatorColor: Colors.purple,
              tabs: [
                Tab(
                  text: "Profile",
                ),
                Tab(
                  text: "Discussions",
                ),
                Tab(
                  text: "Track",
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                ProfileGateWay(widget.highlight),
                DiscussionHome(),
                TrackingHome(
                  highlight: widget.highlight,
                ),
              ],
            ),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
