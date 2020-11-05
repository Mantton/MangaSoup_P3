import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Map userSourceSettings;

  getUserSourceSettings(String selector) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String encodedSettings = _prefs.getString("${selector}_settings");
    if (encodedSettings != null) {
      setState(() {
        userSourceSettings = jsonDecode(encodedSettings);
      });
      debugPrint(userSourceSettings.toString());
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
          (userSourceSettings != null)?
          sourceSettings():Container(),
        ],
      )),
    );
  }

  Widget sourceSettings() {
    List settings = Provider.of<SourceNotifier>(context).source.settings;
    return Column(
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
            Map setting = settings[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 5.h),
              child: Row(
                children: [
                  Text(
                    setting['name'],
                    style: TextStyle(fontSize: 17.sp),
                  ),
                  Spacer(),
                  optionType(setting['type'], setting['selector'], userSourceSettings[setting['value']], buildDropDownMenuItems(setting['options']))
                ],
              ),
            );
          }),
        )
      ],
    );
  }
  List<DropdownMenuItem<Map>> buildDropDownMenuItems(List options) {
    List<DropdownMenuItem<Map>> items = List();
    for (Map listItem in options) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem['name']),
          value: listItem,
        ),
      );
    }
    return items;
  }
  Widget optionType(int type, String optionSelector, var currentValue, List options) {
    switch (type) {
      case 1:
        return PlatformWidget(
          material: (_, __)=>Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.cyan,
                  border: Border.all()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: currentValue,
                    items: options,
                    onChanged: (value) {
                      // setState(() {
                      //   _selectedItem = value;
                      // });
                    }),
              ),
            ),
          ),
        );
      case 2:
        return PlatformWidget(

            /// https://yashodgayashan.medium.com/flutter-dropdown-button-widget-469794c886d0 for the widget
            );
      case 3:
        return Icon(Icons.add);
      default:
        return Icon(Icons.favorite);
    }
  }
}
