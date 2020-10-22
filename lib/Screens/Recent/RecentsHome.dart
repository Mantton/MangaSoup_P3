import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Database/HistoryDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';

import '../../Globals.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryManager _manager = HistoryManager();

  Future<List<ComicHighlight>> initializer;

  Future<List<ComicHighlight>> getHisotry() async {
    return await _manager.getHighlights();
  }

  @override
  void initState() {
    super.initState();
    initializer = getHisotry();
    historyStream.stream.listen((event) {
      initializer = getHisotry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("History"),
      ),
      body: FutureBuilder(
          future: initializer,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Internal Error"),
              );
            }
            if (snapshot.hasData)
              return mainBody(snapshot.data);
            else {
              return Text("No Favorites");
            }
          }),
    );
  }

  Widget mainBody(List<ComicHighlight> comics) {
    return Container(
      child: (comics.length != 0)
          ? SingleChildScrollView(
              child: ComicGrid(
                comics: comics.reversed.toList(),
              ),
            )
          : Center(
              child: Container(
                child: Text("Your History is Empty"),
              ),
            ),
    );
  }
}
