import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

class LibraryBulkDeletePage extends StatefulWidget {
  @override
  _LibraryBulkDeletePageState createState() => _LibraryBulkDeletePageState();
}

class _LibraryBulkDeletePageState extends State<LibraryBulkDeletePage> {
  List<Comic> _selectedItems = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bulk Delete"),
        centerTitle: true,
        actions: [
          _selectedItems.length > 0
              ? IconButton(
                  icon: Icon(CupertinoIcons.delete), onPressed: () => delete())
              : Container()
        ],
      ),
      body: Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
          List<Comic> comics =
              List.of(provider.comics.where((element) => element.inLibrary));
          return ListView.builder(
            itemCount: comics.length,
            itemBuilder: (_, index) => ListTile(
              selectedTileColor: Colors.grey[900],
              selected: _selectedItems.contains(comics[index]),
              onTap: () => toggleSelection(comics[index]),
              title: Text(comics[index].title),
              subtitle: Text(comics[index].source),
            ),
          );
        },
      ),
    );
  }

  toggleSelection(Comic comic) {
    setState(() {
      if (_selectedItems.contains(comic))
        _selectedItems.remove(comic);
      else
        _selectedItems.add(comic);
    });
  }

  delete() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Proceed"),
        content: Text(
          "Are you sure you want to delete ${_selectedItems.length} Comic(s) from your library?",
        ),
        actions: [
          PlatformDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: Text("Proceed"),
            onPressed: () async {
              Navigator.pop(context);
              showLoadingDialog(context);
              try {
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .deleteFromLibrary(_selectedItems);
                Navigator.pop(context);
                showSnackBarMessage(
                    "Removed ${_selectedItems.length} Comic(s) from your library");
              } catch (err) {
                print(err);
                Navigator.pop(context);
                showSnackBarMessage("An Error Occurred");
              }
              setState(() {
                _selectedItems.clear();
              });
            },
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          )
        ],
      ),
    );
  }
}
