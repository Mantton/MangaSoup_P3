import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/settings/pages/general.dart';
import 'package:mangasoup_prototype_3/app/screens/settings/pages/library.dart';
import 'package:mangasoup_prototype_3/app/screens/settings/pages/source/source_setting.dart';

class SettingsHome extends StatefulWidget {
  @override
  _SettingsHomeState createState() => _SettingsHomeState();
}

class _SettingsHomeState extends State<SettingsHome> {
  final List<String> names = [
    "General Settings",
    "Source Settings",
    "Reader Settings",
    "Library Settings"
  ];
  final List pages = [
    GeneralSettings(),
    SourceSettingsPage(),
    SourceSettingsPage(),
    LibrarySettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Container(
          child: ListView.builder(
        itemCount: names.length,
        itemBuilder: (_, int index) => ListTile(
          title: Text(names[index]),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=>pages[index]));
          },
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ),
      )),
    );
  }
}
