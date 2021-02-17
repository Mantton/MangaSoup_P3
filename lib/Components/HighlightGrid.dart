import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:provider/provider.dart';
import 'Images.dart';

class ComicGrid extends StatelessWidget {
  final List<ComicHighlight> comics;
  final int crossAxisCount;

  const ComicGrid({Key key, @required this.comics, this.crossAxisCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, settings, _) {
      return Padding(
        padding: EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: settings.scaleToMatchIntended
                ? settings.comicGridCrossAxisCount.w.toInt()
                : MediaQuery.of(context).orientation.index == 0
                    ? crossAxisCount ?? settings.comicGridCrossAxisCount
                    : 5,
            crossAxisSpacing: 7,
            mainAxisSpacing: 15,
            childAspectRatio:
                settings.comicGridCrossAxisCount >= 4 ? (50 / 100) : (58 / 100),
          ),
          shrinkWrap: true,
          itemCount: comics.length,
          itemBuilder: (BuildContext context, index) => ComicGridTile(
            comic: comics[index],
          ),
        ),
      );
    });
  }

}

class ComicGridTile extends StatelessWidget {
  final ComicHighlight comic;

  const ComicGridTile({Key key, @required this.comic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          debugPrint("${comic.title} @ ${comic.link} /f ${comic.source}");
          Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: true,
              builder: (_) => ProfileHome(highlight: comic),
            ),
          );
        },
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
          header: comic.updateCount != null && comic.updateCount != 0
              ? Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Center(
                          child: AutoSizeText(
                            "${comic.updateCount}",
                            style: updateFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}
