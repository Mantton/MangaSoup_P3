import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/dialogs/library_dialog.dart';
import 'package:provider/provider.dart';

class LibraryOrderManagerPage extends StatefulWidget {
  @override
  _LibraryOrderManagerPageState createState() =>
      _LibraryOrderManagerPageState();
}

class _LibraryOrderManagerPageState extends State<LibraryOrderManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Manage Library"),
      ),
      body: CollectionOrderManager(),
    );
  }
}

class CollectionOrderManager extends StatefulWidget {
  const CollectionOrderManager({
    Key key,
  }) : super(key: key);

  @override
  _CollectionOrderManagerState createState() => _CollectionOrderManagerState();
}

class _CollectionOrderManagerState extends State<CollectionOrderManager> {
  List<Collection> collections = [];

  void _reOrderList(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      Collection c = collections.removeAt(oldIndex);
      collections.insert(newIndex, c);
      Provider.of<DatabaseProvider>(context, listen: false)
          .updateCollectionOrder(collections);
      // Update in Provider
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        // Add Collection Widget
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AddCollection(),
          ),
        ),
        Flexible(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Consumer<DatabaseProvider>(builder: (context, provider, _) {
              collections = List.of(
                  Provider.of<DatabaseProvider>(context, listen: false)
                      .collections);
              collections
                  .removeWhere((element) => element.id == 1); //Remove Default.
              collections.sort((a, b) => a.order.compareTo(b.order));
              return ReorderableListView(
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: false,
                padding: EdgeInsets.all(10),
                onReorder: _reOrderList,
                children: collections
                    .map(
                      (collection) => Card(
                        color: Colors.grey[900],
                        elevation: 2,
                        key: Key(collection.name),
                        child: ListTile(
                          title: Text(
                            collection.name,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          trailing: Icon(
                            Icons.dehaze,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
          ),
        ),
      ],
    );
  }
}
