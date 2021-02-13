import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/dialogs/collection_edit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibrarySettingsPage extends StatefulWidget {
  @override
  _LibrarySettingsPageState createState() => _LibrarySettingsPageState();
}

class _LibrarySettingsPageState extends State<LibrarySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library Settings"),
        centerTitle: true,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
          List<Collection> collections = List.of(provider.collections);
          collections.removeWhere((element) => element.id == 1);
          return Column(
            children: [
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (_, int index) => ListTile(
                    title: Text(
                      collections[index].name,
                      style: notInLibraryFont,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        CupertinoIcons.pen,
                        color: Colors.purple,
                      ),
                      onPressed: () => deleteRenameDialog(collections[index]),
                    ),
                  ),
                ),
              ),
              collections.length != 0
                  ? ListTile(
                      title: Text(
                        "Delete all Collections",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: "Lato",
                            fontSize: 20,),
                      ),
                      onTap: () => deleteAll(),
                    )
                  : Container(),
            ],
          );
        },
      ),
    );
  }

  deleteAll() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Clear Collections"),
        content: Text(
            "This would delete all collections and move any comic in your library to the Default Collection"),
        actions: [
          PlatformDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: Text("Proceed"),
            onPressed: () async {
              Navigator.pop(context);
              try {
                showLoadingDialog(context);
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .clearAllCollection();
              } catch (err) {
                print(err);
                showSnackBarMessage(err.toString());
              }
              Navigator.pop(context);
            },
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );
  }

  deleteRenameDialog(Collection collection) => showPlatformModalSheet(
        context: context,
        builder: (_) => PlatformWidget(
          cupertino: (_, __) => CupertinoActionSheet(
            title: Text(
              "Actions",
              style: notInLibraryFont,
            ),
            cancelButton: CupertinoActionSheetAction(
              child: Text("Cancel"),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              CupertinoActionSheetAction(
                child: Text("Rename Collection"),
                onPressed: () {
                  Navigator.pop(context);
                  collectionEditDialog(
                    context: context,
                    collection: collection,
                  );
                },
              ),
              CupertinoActionSheetAction(
                child: Text("Delete Collection"),
                onPressed: (){
                  Navigator.pop(context);
                  showSnackBarMessage("Not Implemented, Contact Developer");
                },
              ),
            ],
          ),
          material: (_, __) => ListView(
            children: [
              Text(
                "Actions",
                style: notInLibraryFont,
              ),
              SizedBox(
                height: 5.h,
              ),
              ListTile(
                title: Text("Rename Collection"),
                onTap: () {
                  Navigator.pop(context);
                  collectionEditDialog(
                      context: context, collection: collection);
                },
              ),
              ListTile(
                title: Text("Delete Collection"),
              ),
            ],
          ),
        ),
      );
}
