import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/homepage.dart';

class MangaSoupHomePage extends StatefulWidget {
  @override
  _MangaSoupHomePageState createState() => _MangaSoupHomePageState();
}

class _MangaSoupHomePageState extends State<MangaSoupHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class ForYouPage extends StatefulWidget {
  @override
  _ForYouPageState createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<HomePage>> pages;

  Future<List<HomePage>> getPages() async {
    ApiManager _manager = ApiManager();
    List<HomePage> l = List();
    try {
      l = await _manager.getHomePage();
    } catch (err) {
      ErrorManager.analyze(err);
    }
    return l;
  }

  @override
  void initState() {
    pages = getPages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: pages,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Container(
              child: Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pages = getPages();
                    });
                  },
                  child: Text(
                    "${snapshot.error}\n Tap to Retry",
                    textAlign: TextAlign.center,
                    style: notInLibraryFont,
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            List<HomePage> sourcePages = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: List.generate(sourcePages.length, (index) {
                  HomePage page = sourcePages[index];
                  List<ComicHighlight> highlights = [];
                  page.comics.forEach((element) {
                    highlights.add(ComicHighlight.fromMap(element));
                  });
                  if (highlights.isNotEmpty)
                    return Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sourcePages[index].header,
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            sourcePages[index].subHeader,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                              fontFamily: "Lato",
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 250,
                            child: GridView.builder(
                              physics: ScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1.58,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 0,
                              ),
                              shrinkWrap: true,
                              cacheExtent: MediaQuery.of(context).size.width,
                              itemCount: highlights.length,
                              itemBuilder: (BuildContext context, index) =>
                                  ComicGridTile(
                                comic: highlights[index],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  else
                    return Container();
                }),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
