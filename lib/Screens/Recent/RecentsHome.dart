import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Database/HistoryDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/ViewHistoryProvider.dart';
import 'package:provider/provider.dart';

import '../../Globals.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<bool> initializer;

  Future<bool> getHistory() async {
    return await Provider.of<ViewHistoryProvider>(context, listen: false)
        .init();
  }

  @override
  void initState() {
    super.initState();
    initializer = getHistory();
    // historyStream.stream.listen((event) {
    //   initializer = getHisotry();
    // });
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
              return mainBody();
            else {
              return Text("No Favorites");
            }
          }),
    );
  }

  Widget mainBody() {
    return Consumer<ViewHistoryProvider>(builder: (context, provider, _) {
      List<ViewHistory> comics = provider.history;
      return (comics.isNotEmpty)?ListView.builder(
        itemCount: comics.length,
        itemBuilder: (_, int index) => ListTile(
          title: Text(comics[index].highlight.title),
        ),
      ):Container(
        child: Center(
          child: Text("Empty Read History"),
        ),
      );
    });
  }
}
