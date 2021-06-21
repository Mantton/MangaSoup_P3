import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'source_multi_select.dart';

class SourceSettingsPage extends StatefulWidget {
  @override
  _SourceSettingsPageState createState() => _SourceSettingsPageState();
}

class _SourceSettingsPageState extends State<SourceSettingsPage> {
  Map userSourceSettings;
  String _selector;

  getUserSourceSettings(String selector) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String encodedSettings = _prefs.getString("${selector}_settings");
    if (encodedSettings != null) {
      setState(() {
        userSourceSettings = jsonDecode(encodedSettings);
      });
      debugPrint(userSourceSettings.toString());
      print("User Settings initiated");
    } else {
      debugPrint("No User Settings");
    }
  }

  @override
  void initState() {
    super.initState();
    _selector =
        Provider.of<SourceNotifier>(context, listen: false).source.selector;
    getUserSourceSettings(_selector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Source Settings"),
        centerTitle: true,
      ),
      body: Container(
          child: Column(
        children: [
          ListTile(
            title: Text("Clear Source Cookies"),
            subtitle: Text(
                "This would remove authentication credentials and clear CloudFlare bypasses for this source"),
            onTap: () => showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: Text("Confirm Clear"),
                content: Text(
                    "Proceeding will forcefully remove any log in credentials and clear the cloudflare bypasses"),
                actions: [
                  PlatformDialogAction(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  PlatformDialogAction(
                    child: Text("Proceed"),
                    cupertino: (_, __) =>
                        CupertinoDialogActionData(isDestructiveAction: true),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (_selector == "mangadex") {
                        DexHub().logout();
                      }
                      prefs.remove("${_selector}_cookies").then((value) {
                        showSnackBarMessage("Source Cookies cleared!");
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          (userSourceSettings != null) ? sourceSettings() : Container(),
        ],
      )),
    );
  }

  Widget sourceSettings() {
    List settings = Provider.of<SourceNotifier>(context).source.settings;
    return SingleChildScrollView(
      child: Column(
        children: List<Widget>.generate(settings.length, (index) {
          SourceSetting ss = SourceSetting.fromMap(settings[index]);
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Row(
              children: [
                Text(
                  ss.name,
                  style: TextStyle(fontSize: 17),
                ),
                Spacer(),
                optionType(ss)
              ],
            ),
          );
        }),
      ),
    );
  }

  List<DropdownMenuItem<SettingOption>> buildDropDownMenuItems(
      List<SettingOption> options) {
    List<DropdownMenuItem<SettingOption>> items = List();
    for (SettingOption opt in options) {
      items.add(
        DropdownMenuItem<SettingOption>(
          child: Text(opt.name),
          value: opt,
        ),
      );
    }
    return items;
  }

  Widget optionType(SourceSetting setting) {
    String selector =
        Provider.of<SourceNotifier>(context, listen: false).source.selector;
    switch (setting.type) {
      case 1:
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: PlatformSwitch(
            value: SettingOption.fromMap(userSourceSettings[setting.selector])
                    .value ??
                setting.options[0],
            onChanged: (value) async {
              userSourceSettings[setting.selector] = setting.options
                  .singleWhere((element) => element.value == value)
                  .toMap();
              print(userSourceSettings);
              SharedPreferences manager = await SharedPreferences.getInstance();
              await manager.setString(
                  "${selector}_settings", jsonEncode(userSourceSettings));
              sourcesStream.add(selector);
              showSnackBarMessage(
                  "${setting.name} ${value ? "enabled" : "disabled"} !");
              print("Success");
              setState(() {});
            },
          ),
        );
      case 2:
        var v = buildDropDownMenuItems(setting.options);
        SettingOption t =
            SettingOption.fromMap(userSourceSettings[setting.selector]);
        return Container(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[900],
                  border: Border.all()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SettingOption>(
                    value: setting.options.singleWhere(
                        (element) => t.selector == element.selector),
                    items: v,
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(fontSize: 20),
                    onChanged: (value) async {
                      userSourceSettings[setting.selector] = value.toMap();
                      print(userSourceSettings);
                      SharedPreferences manager =
                          await SharedPreferences.getInstance();
                      await manager.setString("${selector}_settings",
                          jsonEncode(userSourceSettings));
                      sourcesStream.add(selector);
                      showSnackBarMessage(
                          "Switched ${setting.name} to ${value.name}");
                      print("Success");
                      setState(() {});
                    }),
              ),
            ),
          ),
        );

      case 3:
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              List<SettingOption> newList = List();

              for (Map map in userSourceSettings[setting.selector]) {
                newList.add(SettingOption.fromMap(map));
              }
              showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          MultiSelectDialog(items: newList, setting: setting))
                  .then((value) async {
                print(value);
                if (value != null) {
                  // If not null update
                  userSourceSettings[setting.selector] = value;

                  print(userSourceSettings);
                  showLoadingDialog(context);
                  SharedPreferences manager =
                      await SharedPreferences.getInstance();
                  await manager.setString(
                      "${selector}_settings", jsonEncode(userSourceSettings));
                  sourcesStream.add(selector);
                  Navigator.pop(context); // Pop Loading Dialog
                  showSnackBarMessage("Updated ${setting.name}!");
                  print("Success");

                  setState(() {});
                }
              });
            },
            child: Text(
              "${userSourceSettings[setting.selector].isNotEmpty ? (userSourceSettings[setting.selector] as List).map((obj) => obj['name']).join(", ") : "Not Set"}",
              style: isEmptyFont,
              softWrap: true,
            ),
          ),
        );
      default:
        return Icon(Icons.favorite);
    }
  }
}
