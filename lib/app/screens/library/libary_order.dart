import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:provider/provider.dart';

class LibraryOrderManagerPage extends StatefulWidget {
  @override
  _LibraryOrderManagerPageState createState() =>
      _LibraryOrderManagerPageState();
}

class _LibraryOrderManagerPageState extends State<LibraryOrderManagerPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text("Library Order"),
        ),
        body: CollectionOrderManager());
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
  List<Collection> collections = List();

  @override
  void initState() {
    collections = List.of(
        Provider.of<DatabaseProvider>(context, listen: false).collections);
    collections.removeWhere((element) => element.order == 0); //Remove Default.
    collections.sort((a, b) => a.order.compareTo(b.order)); // Sort Order
    super.initState();
  }

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
      children: [
        Expanded(
          child: ReorderableListView(
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
          ),
        ),
      ],
    );
  }
}
