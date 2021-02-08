import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:provider/provider.dart';

class ComicInNewDB extends StatefulWidget {
  @override
  _ComicInNewDBState createState() => _ComicInNewDBState();
}

class _ComicInNewDBState extends State<ComicInNewDB> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<DatabaseProvider>(
        builder: (context, provider, _){
          return ComicGrid(comics: provider.comics.map((e) => e.toHighlight()).toList());
        },
      ),
    );
  }
}
