import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';

class MigrateChoseDestination extends StatefulWidget {
  final Comic comic;
  final List<Source> sources;

  const MigrateChoseDestination(
      {Key key, @required this.comic, @required this.sources})
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
          ListView.separated(
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
        ],
      ),
    );
  }
}

class BuildSearchResult extends StatefulWidget {
  final Comic initial;
  final Source source;

  const BuildSearchResult(
      {Key key, @required this.initial, @required this.source})
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
      );
  }
}

class BuildResultList extends StatelessWidget {
  final List<ComicHighlight> result;

  const BuildResultList({Key key, @required this.result}) : super(key: key);

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
        itemBuilder: (BuildContext context, index) => ComicGridTile(
          comic: result[index],
        ),
      ),
    );
  }
}
