import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Screens/Explore/ForYou.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';

class MultiSearchResult extends StatefulWidget {
  final List<Source> sources;

  const MultiSearchResult({Key key, this.sources}) : super(key: key);

  @override
  _MultiSearchResultState createState() => _MultiSearchResultState();
}

class _MultiSearchResultState extends State<MultiSearchResult> {
  String query;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            header(),
            query != null ? body() : Container(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: searchForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    return Positioned(
      top: 85,
      left: 0,
      right: 0,
      bottom: 0,
      child: searchBody(),
    );
  }

  Widget searchForm() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TextField(
        decoration: mangasoupInputDecoration("Search..."),
        cursorColor: Colors.grey,
        maxLines: 1,
        style: TextStyle(
          height: 1.7,
          color: Colors.grey,
          fontSize: 18,
        ),
        onSubmitted: (value) async {
          setState(() {
            query = value;
          });
        },
      ),
    );
  }

  Widget searchBody() {
    return ListView.separated(
      itemBuilder: (_, index) => BuildResults(
        source: widget.sources[index],
        query: query,
      ),
      separatorBuilder: (_, index) => SizedBox(
        height: 7,
      ),
      itemCount: widget.sources.length,
    );
  }
}

class BuildResults extends StatelessWidget {
  final Source source;
  final String query;

  const BuildResults({Key key, this.source, this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: FutureBuilder(
        future: ApiManager().search(source.selector, query.toLowerCase()),
        builder: (_, snapshot) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${source.name}, ${snapshot.data?.length ?? 0} Result(s)",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: 7,
            ),
            snapshotLogic(snapshot),
          ],
        ),
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
            "An Error Occurred",
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
      return ListGridComicHighlight(
        highlights: snapshot.data,
      );
  }
}
