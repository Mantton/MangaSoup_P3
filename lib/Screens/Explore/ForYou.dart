import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/homepage.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:provider/provider.dart';


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
            List<HomePage> pages = snapshot.data;
            return ListView.separated(
                itemBuilder: (_, index) => pages[index].comics.isNotEmpty
                    ? CollectionGroupView(
                        title: pages[index].header,
                        subtitle: pages[index].subHeader,
                        highlights: pages[index]
                            .comics
                            .map((e) => ComicHighlight.fromMap(e))
                            .toList(),
                      )
                    : Container(),
                separatorBuilder: (_, index) => SizedBox(
                      height: 0,
                    ),
                itemCount: pages.length);
          } else {
            return Container();
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class CollectionGroupView extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ComicHighlight> highlights;

  const CollectionGroupView({this.title, this.subtitle, this.highlights});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 10, 5, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontFamily: "Lato",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListGridComicHighlight(highlights: highlights),
          ],
        ),
      ),
    );
  }
}

class ListGridComicHighlight extends StatelessWidget {
  const ListGridComicHighlight({
    Key key,
    @required this.highlights,
  }) : super(key: key);

  final List<ComicHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, settings, _) {
      return Container(
        height: 300,
        child: GridView.builder(
          physics: ScrollPhysics(),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio:
                settings.comicGridMode == 0 ? (100 / 53) : (100 / 60),
            mainAxisSpacing: 10,
            crossAxisSpacing: 0,
          ),
          shrinkWrap: true,
          cacheExtent: MediaQuery.of(context).size.width,
          itemCount: highlights.length,
          itemBuilder: (BuildContext context, index) => ComicGridTile(
            comic: highlights[index],
          ),
        ),
      );
    });
  }
}
