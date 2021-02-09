import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:provider/provider.dart';
import 'Images.dart';

class ComicGrid extends StatefulWidget {
  final List<ComicHighlight> comics;
  final int crossAxisCount;

  const ComicGrid({Key key, @required this.comics, this.crossAxisCount})
      : super(key: key);

  @override
  _ComicGridState createState() => _ComicGridState();
}

class _ComicGridState extends State<ComicGrid> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<PreferenceProvider>(builder: (context, settings, _) {
      return Padding(
        padding: EdgeInsets.all(8.0.w),
        child: GridView.builder(
          physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                widget.crossAxisCount ?? settings.comicGridCrossAxisCount,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 15.w,
            childAspectRatio: settings.comicGridCrossAxisCount == 3
                ? (53 / 100)
                : (58 / 100), // 60 for 2, 53 for 3
          ),
          shrinkWrap: true,
          itemCount: widget.comics.length,
          itemBuilder: (BuildContext context, index) => ComicGridTile(
            comic: widget.comics[index],
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    child: Container(
                      width: 300.w,
                      child: SoupImage(
                        url: comic.thumbnail,
                        referer: comic.imageReferer,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.black54,
                  height: 59.h,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: AutoSizeText(
                        comic.title,
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // fontSize: 17.sp,
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

                        minFontSize: Provider.of<PreferenceProvider>(context)
                                    .comicGridCrossAxisCount ==
                                3
                            ? 17.sp
                            : 20.sp, //17 for 3, 20 for 2
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          header: comic.updateCount != null && comic.updateCount != 0
              ? Padding(
                  padding: EdgeInsets.all(5.0.w),
                  child: Container(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(2.0.w),
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
