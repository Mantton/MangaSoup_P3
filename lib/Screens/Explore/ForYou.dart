import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/homepage.dart';
class MangaSoupHomePage extends StatefulWidget {
  @override
  _MangaSoupHomePageState createState() => _MangaSoupHomePageState();
}

class _MangaSoupHomePageState extends State<MangaSoupHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}

class ForYouPage extends StatefulWidget {
  @override
  _ForYouPageState createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  Future<List<HomePage>> pages;

  Future<List<HomePage>> getPages() async {
    ApiManager _manager = ApiManager();
    return await _manager.getHomePage();
  }

  @override
  void initState() {
    pages = getPages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    "An Error Occured\n ${snapshot.error}\n Tap to Retry",
                    textAlign: TextAlign.center,
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

                  return Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sourcePages[index].header,
                          style: TextStyle(fontSize: 30),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          sourcePages[index].subHeader,
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        highlights.length <= 6
                            ? ComicGrid(
                          comics: highlights,
                        )
                            : Container(
                          child: CarouselSlider(

                            options: CarouselOptions(
                              aspectRatio: 1,
                              height: 300.h,
                              viewportFraction: .4,
                              pauseAutoPlayOnManualNavigate: true,

                              enlargeCenterPage: true,
                              // disableCenter: true,
                              autoPlayInterval: Duration(
                                seconds: 10,
                              ),

                              scrollDirection: Axis.horizontal,
                              autoPlay: false,
                            ),
                            items: highlights
                                .map((e) => ComicGridTile(comic: e))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}