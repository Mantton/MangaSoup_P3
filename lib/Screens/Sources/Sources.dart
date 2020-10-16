import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:collection/collection.dart';

class SourcesPage extends StatefulWidget {
  @override
  _SourcesPageState createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  ApiManager server = ApiManager();


  // Retrieve Source from Server
  Future<Map> getSources() async {
    List<Source> sources =
        await server.getServerSources("live"); // Retrieve Source
    Map sorted =
        groupBy(sources, (Source obj) => obj.sourcePack); // Group Source
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getSources(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          if (snapshot.hasData) {
            Map sourcePacks = snapshot.data;
            List keys = sourcePacks.keys.toList();
            List values = sourcePacks.values.toList();
            return DefaultTabController(
              length: sourcePacks.length,
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Sources"),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(CupertinoIcons.info),
                      onPressed: () {},
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.purple,
                    labelColor: Colors.purple,
                    tabs: List<Widget>.generate(
                      sourcePacks.length,
                      (index) => Tab(
                        text: keys[index],
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: List<Widget>.generate(
                    sourcePacks.length,
                    (int index) {
                      List<Source> _sources = values[index];
                      return Container(
                        padding: EdgeInsets.all(8),
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: .77, // todo, variable resizing
                            ),
                            itemCount: _sources.length,
                            itemBuilder: (BuildContext context, int i) {
                              Source source = _sources[i];
                              return GestureDetector(
                                onTap: () {
                                  debugPrint(source.thumbnail);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: (!source.isEnabled)
                                            ? Colors.red
                                            : (source.selector !=
                                                    'mangadex') // todo change to active source
                                                ? (source.vipProtected)
                                                    ? Colors.amber
                                                    : Colors.grey[900]
                                                : Colors.purple),
                                  ),
                                  child: GridTile(
                                    child: Image.network(source.thumbnail),

                                    // CachedNetworkImage(
                                    //   imageUrl: source.thumbnail,
                                    //   fadeInDuration:
                                    //       Duration(milliseconds: 200),
                                    //   placeholder: (context, url) => Center(
                                    //     child: CupertinoActivityIndicator(),
                                    //   ),
                                    // ),
                                    footer: Center(
                                      child: FittedBox(
                                        child: Text(
                                          source.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    header: (!source.vipProtected)
                                        ? Container()
                                        : Container(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.verified_sharp,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  "VIP",
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                      );
                    },
                  ),
                ),
              ),
            );
          } else
            // todo, raise error here
            return Scaffold(
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'An error Occurred while retrieving sources',
                        style: TextStyle(color: Colors.white),
                      ),
                      Center(
                        child: InkWell(
                          child: Text(
                            "Retry",
                            style: TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
