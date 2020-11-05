import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map userSourceSettings;

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
    String selector =
        Provider.of<SourceNotifier>(context, listen: false).source.selector;
    getUserSourceSettings(selector);
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
        children: [
          (userSourceSettings != null) ? sourceSettings() : Container(),
        ],
      )),
    );
  }

  Widget sourceSettings() {
    List settings = Provider.of<SourceNotifier>(context).source.settings;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Text("Source Settings", style: TextStyle(fontSize: 20.sp)),
          ),
          Divider(
            color: Colors.grey,
          ),
          Column(
            children: List<Widget>.generate(settings.length, (index) {
              SourceSetting ss = SourceSetting.fromMap(settings[index]);
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 5.h),
                child: Row(
                  children: [
                    Text(
                      ss.name,
                      style: TextStyle(fontSize: 17.sp),
                    ),
                    Spacer(),
                    optionType(ss)
                  ],
                ),
              );
            }),
          )
        ],
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
        return PlatformSwitch(
          value:
              SettingOption.fromMap(userSourceSettings[setting.selector]).value,
          onChanged: (value) async {
            userSourceSettings[setting.selector] = setting.options
                .singleWhere((element) => element.value == value)
                .toMap();

            print(userSourceSettings);
            SharedPreferences manager = await SharedPreferences.getInstance();
            await manager.setString(
                "${selector}_settings", jsonEncode(userSourceSettings));
            print("Success");
            setState(() {});
          },
        );
      case 2:
        var v = buildDropDownMenuItems(setting.options);
        SettingOption t =
            SettingOption.fromMap(userSourceSettings[setting.selector]);
        return Container(
          child: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Container(
              padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
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
                    style: TextStyle(fontSize: 20.sp),
                    onChanged: (value) async {
                      userSourceSettings[setting.selector] = value.toMap();
                      print(userSourceSettings);
                      SharedPreferences manager =
                          await SharedPreferences.getInstance();
                      await manager.setString("${selector}_settings",
                          jsonEncode(userSourceSettings));
                      print("Success");
                      setState(() {});
                    }),
              ),
            ),
          ),
        );

      case 3:
        return Icon(Icons.add);
      default:
        return Icon(Icons.favorite);
    }
  }
}
