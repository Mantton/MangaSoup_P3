import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/test_preference.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Source> sources = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Discover"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.cloud),
              onPressed: () {
                Navigator.pushNamed(context, '/sources', );
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                debugPrint('Go To Search Page');
              },
              color: Colors.white,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: TabBar(
              indicatorColor: Colors.transparent,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              tabs: <Widget>[
                Tab(
                  text: "For You",
                ),
                Tab(
                  text: "All Comics",
                ),
                Tab(
                  text: "Latest",
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              color: Colors.grey,
            ),
            Container(
              color: Colors.blueGrey[800],
              child: Center(
                child: (sources.length == 0)
                    ? CupertinoButton(
                        child: Text("TEST"),
                        onPressed: simulate,
                      )
                    : Container(
                        child: GridView.builder(
                            itemCount: sources.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4),
                            itemBuilder: (context, index) {
                              Source source = sources[index];
                              return GridTile(
                                footer: Text(source.name),
                                child: Image.network(source.thumbnail),
                              );
                            }),
                      ),
              ),
            ),
            Container(
                child: CupertinoButton(
              child: Text("RETRIEVE"),
              onPressed: retrieve,
            ))
          ],
        ),
      ),
    );
  }

  simulate() async {
    ApiManager re = ApiManager();
    // await re.getAll("mangadex", "9", 1, {});
    // List x = await re.getServerSources("live");
    // setState(() {
    //   sources = x;
    // });

    TestPreference _t = TestPreference();
    await _t.init();
    _t.setName("tester");

    debugPrint("OK");
  }

  retrieve() async {
    TestPreference _t = TestPreference();
    await _t.init();
    String y = _t.getName();
    debugPrint(y);
  }
}
