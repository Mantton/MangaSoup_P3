import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

class LibrarySearch extends StatefulWidget {
  @override
  _LibrarySearchState createState() => _LibrarySearchState();
}

class _LibrarySearchState extends State<LibrarySearch> {
  List<Comic> _results = List();

  @override
  void initState() {
    super.initState();
    searchLibrary("");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: mangasoupInputDecoration("Search Library"),
          onChanged: searchLibrary,
        ),
      ),
      body: Container(
        child: ComicGrid(
          comics: _results.map((e) => e.toHighlight()).toList(),
        ),
      ),
    );
  }

  void searchLibrary(String query) {
    setState(() {
      _results = Provider.of<DatabaseProvider>(context, listen: false)
          .searchLibrary(query);
    });
  }
}
