import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';

class ProfilePage extends StatefulWidget {
  final ComicProfile profile;

  const ProfilePage({Key key, @required this.profile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ComicProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_profile != null)
          ? Center(
              child: Text(_profile.description),
            )
          : Center(
              child: LoadingIndicator(),
            ),
    );
  }
}
