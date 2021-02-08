import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibraryOrderManagerPage extends StatefulWidget {
  @override
  _LibraryOrderManagerPageState createState() => _LibraryOrderManagerPageState();
}

class _LibraryOrderManagerPageState extends State<LibraryOrderManagerPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text("Library Order"),
      ),
      body: CollectionOrderManager()
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

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      List<Collection> collections = List.of(provider.collections);
      collections
          .removeWhere((element) => element.order == 0); //Remove Default.
      collections.sort((a, b) => a.order.compareTo(b.order)); // Sort Order

      // Uncomment this line below for collection debugging
      // print(collections.map((e) => "${e.name}: ${e.order}").toList() );
      return ReorderableListView(
        padding:EdgeInsets.all(10.w),
        onReorder: provider.updateCollectionOrder,
        children: [
          for (final collection in collections)
            SizedBox(
              height: 70,
              key: ValueKey(collection.name),
              child: Center(
                child: Card(
                  color: Colors.grey[900],
                  elevation: 2,
                  child: ListTile(
                    title: Text(collection.name, style: TextStyle(fontSize:20 ),),
                    trailing: Icon(
                      Icons.dehaze,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/*
* Settings: Order, View
* */
