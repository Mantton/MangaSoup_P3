import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:provider/provider.dart';

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
          return Column(
            children: [
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.collections.length,
                  itemBuilder: (_, int index) => ListTile(
                    title: Text(provider.collections[index].name),
                    trailing: IconButton(
                      icon: Icon(CupertinoIcons.pen),
                      onPressed: () {
                        // todo, open actions dialog, rename or delete
                      },
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text("Delete all Collections"),
                onTap: () => deleteAll(),
              )
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
            onPressed: ()async{
              Navigator.pop(context);
              try{
                showLoadingDialog(context);
                await Provider.of<DatabaseProvider>(context, listen: false).clearAllCollection();
              }catch(err){
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
}
