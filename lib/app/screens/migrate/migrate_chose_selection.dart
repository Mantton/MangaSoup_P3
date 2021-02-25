import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/migrate/migrate_compare_and_complete.dart';

class MigrateChoseDestination extends StatefulWidget {
  final Comic comic;
  final List<Source> sources;

  const MigrateChoseDestination({Key key, @required this.comic, @required this.sources})
      : super(key: key);

  @override
  _MigrateChoseDestinationState createState() =>
      _MigrateChoseDestinationState();
}

class _MigrateChoseDestinationState extends State<MigrateChoseDestination> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Destination"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(widget.comic.title),
            subtitle: Text(widget.comic.source),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (_, index) => BuildSearchResult(
                initial: widget.comic,
                source: widget.sources[index],
              ),
              separatorBuilder: (_, index) => SizedBox(
                height: 15,
              ),
              itemCount: widget.sources.length,
            ),
          ),
        ],
      ),
    );
  }
}

class BuildSearchResult extends StatefulWidget {
  final Comic initial;
  final Source source;

  const BuildSearchResult({Key key, @required this.initial, @required this.source})
      : super(key: key);

  @override
  _BuildSearchResultState createState() => _BuildSearchResultState();
}

class _BuildSearchResultState extends State<BuildSearchResult> {
  Future<List<ComicHighlight>> results;

  @override
  void initState() {
    results = ApiManager()
        .search(widget.source.selector, widget.initial.title.toLowerCase());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${widget.source.name}",
            style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
                fontSize: 25),
          ),
          SizedBox(
            height: 7,
          ),
          FutureBuilder(
            future: results,
            builder: (_, snapshot) => snapshotLogic(snapshot),
          ),
        ],
      ),
    );
  }

  snapshotLogic(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return Container(
        height: 100,
        child: Center(
          child: LoadingIndicator(),
        ),
      );
    else if (snapshot.hasError)
      return Container(
        height: 100,
        child: Center(
          child: Text(
            "${snapshot.error}",
            style: notInLibraryFont,
            textAlign: TextAlign.center,
          ),
        ),
      );
    else if (!snapshot.hasData)
      return Container(
        height: 100,
        child: Center(
          child: Text(
            "Critical Error\nYou should not be seeing this",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    else if (snapshot.data.length == 0)
      return Container(
        height: 100,
        child: Center(
          child: Text("No Results", style: notInLibraryFont),
        ),
      );
    else
      return BuildResultList(
        result: snapshot.data,
        initial: widget.initial,
      );
  }
}

class BuildResultList extends StatelessWidget {
  final Comic initial;
  final List<ComicHighlight> result;

  const BuildResultList(
      {Key key, @required this.result, @required this.initial})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: GridView.builder(
        physics: ScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.58,
          mainAxisSpacing: 5,
          crossAxisSpacing: 0,
        ),
        shrinkWrap: true,
        cacheExtent: MediaQuery.of(context).size.width,
        itemCount: result.length,
        itemBuilder: (BuildContext context, index) {
          ComicHighlight comic = result[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MigrateCompare(current: initial, destination: comic),
              ),
            ),
            child: GridTile(
              child: Container(
                // color: Colors.grey,
                child: Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        child: SoupImage(
                          url: comic.thumbnail,
                          referer: comic.imageReferer,
                          // fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: AutoSizeText(
                        comic.title,
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // fontSize: 17,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 7.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 2,

                        presetFontSizes: [17, 15],

                        // maxFontSize: 40,
                        // stepGranularity: 2,
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
