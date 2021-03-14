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
                : settings.comicGridCrossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio:
                settings.comicGridMode == 0 ? (53 / 100) : (60 / 100),
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
      key: UniqueKey(),
      child: GestureDetector(
        onTap: () {
          // debugPrint("${comic.title} @ ${comic.link} /f ${comic.source}");
          Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: true,
              builder: (_) => ProfileHome(highlight: comic),
            ),
          );
        },
        child: Provider.of<PreferenceProvider>(context).comicGridMode == 1
            ? CompactGridTile(comic: comic)
            : SeparatedGridTile(comic: comic),
      ),
    );
  }
}

class SeparatedGridTile extends StatelessWidget {
  const SeparatedGridTile({
    Key key,
    @required this.comic,
  }) : super(key: key);

  final ComicHighlight comic;

  @override
  Widget build(BuildContext context) {
    return GridTile(
        child: Container(
          // color: Colors.grey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: SoupImage(
                  url: comic.thumbnail,
                  referer: comic.imageReferer,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: AutoSizeText(
                            comic.title,
                            style: TextStyle(
                                fontFamily: "Roboto",
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                            textAlign: TextAlign.left,
                            // overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,

                            // presetFontSizes: [17],
                            // overflowReplacement: Text("..."),
                            minFontSize: 14,
                            maxFontSize: 17,
                            // stepGranularity: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        header: GridHeader(comic: comic));
  }
}

class GridHeader extends StatelessWidget {
  const GridHeader({
    Key key,
    @required this.comic,
  }) : super(key: key);

  final ComicHighlight comic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          comic.updateCount != null && comic.updateCount > 0
              ? Container(
                  padding: EdgeInsets.all(4.5),
                  margin: EdgeInsets.all(2),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      "${comic.updateCount}",
                      style: updateFont,
                    ),
                  ),
                )
              : Container(),
          comic.unreadCount != null &&
                  comic.unreadCount > 0 &&
                  Provider.of<PreferenceProvider>(context).showUnreadCount
              ? Container(
                  padding: EdgeInsets.all(4.5),
                  margin: EdgeInsets.all(2),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8.5),
                  ),
                  child: Center(
                    child: AutoSizeText(
                      "${comic.unreadCount}",
                      style: updateFont,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class CompactGridTile extends StatelessWidget {
  const CompactGridTile({
    Key key,
    @required this.comic,
  }) : super(key: key);

  final ComicHighlight comic;

  @override
  Widget build(BuildContext context) {
    return GridTile(
        footer: Container(
          alignment: Alignment.topLeft,
          color: Color.fromRGBO(0, 0, 0, .70),
          padding: EdgeInsets.only(top: 3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
                child: AutoSizeText(
                  comic.title,
                  style: TextStyle(
                    fontFamily: "Roboto",
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,

                  // maxFontSize: 40,
                  // stepGranularity: 2,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          // color: Colors.grey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                  child: SoupImage(
                    url: comic.thumbnail,
                    referer: comic.imageReferer,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        header: GridHeader(
          comic: comic,
        ));
  }
}
