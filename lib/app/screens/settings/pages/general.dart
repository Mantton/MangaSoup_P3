import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:provider/provider.dart';

class GeneralSettings extends StatefulWidget {
  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  List<DropdownMenuItem> cgcacItems = [
    DropdownMenuItem(
      child: Text("2"),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text("3"),
      value: 3,
    ),
    DropdownMenuItem(
      child: Text("4"),
      value: 4,
    ),
    DropdownMenuItem(
      child: Text("5"),
      value: 5,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("General Settings"),
      ),
      body: SingleChildScrollView(
        child: Consumer<PreferenceProvider>(builder: (context, settings, _) {
          return Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Comic Grid",
                      style: notInLibraryFont,
                    ),
                    Divider(),

                    ListTile(
                      title: Text(
                        "Comic Grid Column Count",
                        style: notInLibraryFont,
                      ),
                      subtitle: Text(
                        "Number of comics in a row"
                      ),
                      trailing: Container(
                        padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[900],
                            border: Border.all()),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: List.of(cgcacItems)
                                .singleWhere((element) =>
                            element.value ==
                                settings.comicGridCrossAxisCount)
                                .value,
                            items: cgcacItems,
                            onChanged: (p) => settings.setCrossAxisCount(p),
                          ),
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      title: Text("Scale Grid to match intended look", style: notInLibraryFont,),
                      subtitle: Text("This would automatically scale the cross axis count to match the intended look of the app\nThis would override the Grid Count"),
                      value: settings.scaleToMatchIntended,
                      onChanged:(v)=>
                          settings.setSTMI(v),
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
