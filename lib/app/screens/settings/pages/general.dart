import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/downloads_testing.dart';
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
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "App",
                  style: notInLibraryFont,
                ),
                Divider(),
                SwitchListTile.adaptive(
                  title: Text("Check for Updates on launch"),
                  subtitle: Text(
                    "When enabled the app will automatically check for updates when the app is launched",
                  ),
                  value: settings.updateOnStartUp,
                  onChanged: (v) => settings.setUpdateOnStartUp(v),
                ),
                SizedBox(
                  height: 10,
                ),
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
                  subtitle: Text("Number of comics in a row"),
                  trailing: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
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
                  title: Text(
                    "Scale Grid to match intended look",
                    style: notInLibraryFont,
                  ),
                  subtitle: Text(
                      "This would automatically scale the cross axis count to match the intended look of the app\nThis would override the Grid Count"),
                  value: settings.scaleToMatchIntended,
                  onChanged: (v) => settings.setSTMI(v),
                ),
                ListTile(
                  title: Text(
                    "Comic GridTile Look",
                    style: notInLibraryFont,
                  ),
                  subtitle: Text("OverAll Look of a GridTile"),
                  trailing: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[900],
                        border: Border.all()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: settings.comicGridMode,
                        items:
                            settings.buildItems(settings.comicGridModeOptions),
                        onChanged: (p) => settings.setComicGridMode(p),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Image Cache",
                  style: notInLibraryFont,
                ),
                Divider(),
                FutureBuilder(
                  future: getCacheSize(),
                  builder: (_, snap) {
                    if (snap.hasData)
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "${snap.data['count']} Image(s) consuming ${snap.data['size']} MB",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontFamily: "Lato",
                          ),
                        ),
                      );
                    else
                      return LoadingIndicator();
                  },
                ),
                ListTile(
                  title: Text(
                    "Clear Image Cache",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 17,
                      fontFamily: "Lato",
                    ),
                  ),
                  trailing: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onTap: () {
                    setState(() {
                      DefaultCacheManager manager = DefaultCacheManager();
                      manager.emptyCache(); //clears all data in cache.
                      showSnackBarMessage(
                        "Image Cache Cleared!",
                      );
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Downloads",
                  style: notInLibraryFont,
                ),
                Divider(),
                FutureBuilder(
                  future: getDownloadSize(),
                  builder: (_, snap) {
                    if (snap.hasData)
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "${snap.data['count']} Image(s) consuming ${snap.data['size']} MB",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontFamily: "Lato",
                          ),
                        ),
                      );
                    else
                      return LoadingIndicator();
                  },
                ),
                ListTile(
                  title: Text(
                    "Delete all Downloads",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 17,
                      fontFamily: "Lato",
                    ),
                  ),
                  trailing: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onTap: () => showPlatformDialog(
                    context: context,
                    builder: (_) => PlatformAlertDialog(
                      title: Text("Delete Downloads"),
                      content: Text(
                        "Are you sure you want to delete all downloaded content?",
                      ),
                      actions: [
                        PlatformDialogAction(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                          cupertino: (_, __) => CupertinoDialogActionData(
                            isDefaultAction: true,
                          ),
                        ),
                        PlatformDialogAction(
                          child: Text("Proceed"),
                          onPressed: () async {
                            Navigator.pop(context); // Pop Dialog
                            showLoadingDialog(context);
                            try {
                              await Provider.of<DatabaseProvider>(context,
                                      listen: false)
                                  .deleteAllDownloads(context);
                              Navigator.pop(context);
                              showSnackBarMessage("Downloads Cleared!");
                            } catch (err, stacktrace) {
                              Navigator.pop(context);
                              showSnackBarMessage("Error", error: true);
                              print(err);
                              print(stacktrace);
                            }
                          },
                          cupertino: (_, __) => CupertinoDialogActionData(
                            isDestructiveAction: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
