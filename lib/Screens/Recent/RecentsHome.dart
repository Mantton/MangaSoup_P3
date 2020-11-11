import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Providers/ViewHistoryProvider.dart';
import 'package:provider/provider.dart';

import 'RecentsHighlightViews.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<bool> initializer;
  int mode = 1;

  Future<bool> getHistory() async {
    return await Provider.of<ViewHistoryProvider>(context, listen: false)
        .init();
  }

  @override
  void initState() {
    super.initState();
    initializer = getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("History"),
        actions: [
          IconButton(
              icon: Icon((mode != 1)
                  ? CupertinoIcons.square_grid_3x2_fill
                  : CupertinoIcons.list_dash),
              onPressed: () {
                setState(() {
                  if (mode == 1)
                    mode = 2;
                  else
                    mode = 1;
                });
              })
        ],
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
      return (provider.history.isNotEmpty)
          ? HistoryView(
              mode: mode,
              comics: provider.history.reversed.toList(),
            ) // Reverse Returns the latest entry first
          : Container(
              child: Center(
                child: Text(
                  "Empty Read History",
                  style: TextStyle(fontSize: 30.h),
                ),
              ),
            );
    });
  }
}
