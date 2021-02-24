import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';

class MigrateSourceSelector extends StatefulWidget {
  final Comic comic;

  const MigrateSourceSelector({Key key, this.comic}) : super(key: key);

  @override
  _MigrateSourceSelectorState createState() => _MigrateSourceSelectorState();
}

class _MigrateSourceSelectorState extends State<MigrateSourceSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Migrate Source"),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "Top Sources",
                        style: notInLibraryFont,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // todo, show search results from the top 4 sources, i.e here, dex, park, nelo
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
        },
      ),
    );
  }
}
