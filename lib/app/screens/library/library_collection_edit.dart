import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:provider/provider.dart';


class CollectionEdit extends StatefulWidget {
  final int collectionId;

  const CollectionEdit({Key key, this.collectionId}) : super(key: key);
  @override
  _CollectionEditState createState() => _CollectionEditState();
}

class _CollectionEditState extends State<CollectionEdit> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (BuildContext context, provider, _) {
        Collection collection = provider.retrieveCollection(widget.collectionId);
        return Scaffold(
          appBar: AppBar(
            title: Text("${collection.name}"),
          ),
          body: Container(),
        );
      }
    );
  }
}
