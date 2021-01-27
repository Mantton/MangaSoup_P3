import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

class LibraryHome extends StatefulWidget {
  @override
  _LibraryHomeState createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      return ListView.builder(
          itemCount: provider.comicCollections.length,
          itemBuilder: (_, int index) {
            ComicCollection c = provider.comicCollections[index];
            Comic comic = provider.retrieveComic(c.comicId);
            Collection collection = provider.retrieveCollection(c.collectionId);
            return ListTile(
              title: Text(comic.title),
              subtitle: Text(collection.name),
            );
          });
    });
  }
}
