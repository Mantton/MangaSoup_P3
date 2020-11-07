import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/GateWay.dart';

import 'Images.dart';

class FavoritesGrid extends StatefulWidget {
  final List<Favorite> favorites;
  final int crossAxisCount;

  const FavoritesGrid({Key key, @required this.favorites, this.crossAxisCount})
      : super(key: key);

  @override
  _FavoritesGridState createState() => _FavoritesGridState();
}

class _FavoritesGridState extends State<FavoritesGrid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: GridView.builder(
        physics: ScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount ?? 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
          childAspectRatio: 65 / 100,
        ),
        shrinkWrap: true,
        itemCount: widget.favorites.length,
        itemBuilder: (BuildContext context, index) => FavoritesTile(
          favorite: widget.favorites[index],
        ),
      ),
    );
  }
}

class FavoritesTile extends StatelessWidget {
  final Favorite favorite;

  const FavoritesTile({Key key, @required this.favorite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ComicHighlight comic = favorite.highlight;
    return Container(
      child: GestureDetector(
        onTap: () {
          debugPrint("${comic.title} @ ${comic.link} /f ${comic.source}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileGateWay(comic),
            ),
          );
        },
        child: GridTile(
          header: (favorite.updateCount == 0 || favorite.updateCount != null)
              ? Container()
              : Container(
                  padding: EdgeInsets.all(
                    5.w,
                  ),
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    child: Text(
                      "${favorite.updateCount}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 25.sp),
                    ),
                    backgroundColor: Colors.red[700],
                  ),
                ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            child: Container(
              width: 400.w,
              height: 500.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: SoupImage(
                url: comic.thumbnail,
              ),
            ),
          ),
          footer: Container(
            color: Colors.black54,
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Text(
                comic.title,
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
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
                    ]),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
