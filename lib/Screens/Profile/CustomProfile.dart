import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';

class CustomProfilePage extends StatefulWidget {
  final ComicProfile profile;

  const CustomProfilePage({Key key, @required this.profile}) : super(key: key);

  @override
  _CustomProfilePageState createState() => _CustomProfilePageState();
}

class _CustomProfilePageState extends State<CustomProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(widget.profile.title),
        ),
      ),
    );
  }
}
