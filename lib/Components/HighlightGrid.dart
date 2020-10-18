import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ComicGrid extends StatefulWidget {
  final List<ComicHighlight> comics;

  const ComicGrid({Key key, @required this.comics}) : super(key: key);

  @override
  _ComicGridState createState() => _ComicGridState();
}

class _ComicGridState extends State<ComicGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
          childAspectRatio: 65 / 100),
      shrinkWrap: true,
      itemCount: widget.comics.length,
      itemBuilder: (BuildContext context, index) => GestureDetector(
        onTap: () {},
        child: ComicGridTile(
          comic: widget.comics[index],
        ),
      ),
    );
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
          debugPrint(comic.title);
        },
        child: GridTile(
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
              child: Image.network(
                comic.thumbnail,
                fit: BoxFit.fill,
              ),
            ),
          ),
          footer: Container(
            color: Colors.black38,
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
                          color: Colors.black),
                      Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black)
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