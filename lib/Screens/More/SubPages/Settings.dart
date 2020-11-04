import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Future<Map> userSourceSettings;

  Future<Map> getUserSourceSettings(String selector) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String encodedSettings = _prefs.getString("${selector}_settings");
    Map userSourceSttn = jsonDecode(encodedSettings);
    return userSourceSttn;
  }

  @override
  void initState() {
    super.initState();
    String selector = Provider.of<SourceNotifier>(context, listen: false).source.selector;
    userSourceSettings = getUserSourceSettings(selector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Container(
          child: Column(
            children: [sourceSettings()],
          )),
    );
  }

  Widget sourceSettings() {
    List settings = Provider
        .of<SourceNotifier>(context)
        .source
        .settings;
    return Column(
      children: [
        Text("Source Settings"),
        Divider(
          color: Colors.grey,
        ),
        Column(
          children: List<Widget>.generate(
              settings.length,
                  (index) {
                Map setting = settings[index];
                return Row(
                  children: [
                    Text(setting['name']),
                    Spacer(),
                    optionType(setting['type'])
                  ],
                );
              }
          ),
        )
      ],
    );
  }

  Widget optionType(int type) {
    switch (type) {
      case 1:
        return PlatformSwitch(value:false, onChanged: null);
      case 2:
        return Icon(Icons.add_a_photo);
      case 3:
        return Icon(Icons.add);
      default:
        return Icon(Icons.favorite);
    }
  }
}
