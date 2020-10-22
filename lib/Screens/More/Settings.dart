import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            Provider.of<SourceNotifier>(context).source.settings.toString() ??
                "No Settings Available for this source",
          ),
        ),
      ),
    );
  }
}
