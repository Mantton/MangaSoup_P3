import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/tag_widget.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/widgets/content_preview.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenericProfilePage extends StatefulWidget {
  final Profile profile;
  final int comicId;

  const GenericProfilePage({Key key, this.profile, this.comicId})
      : super(key: key);

  @override
  _GenericProfilePageState createState() => _GenericProfilePageState();
}

class _GenericProfilePageState extends State<GenericProfilePage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          // read chapters
          Comic comic = provider.retrieveComic(widget.comicId);
          return homeView(comic: comic);
        },
      ),
    );
  }

  Widget homeView({@required Comic comic}) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      profileHeader(comic),
                      Divider(
                        height: 5.h,
                        indent: 5.w,
                        endIndent: 5.w,
                        color: Colors.white12,
                        thickness: 2,
                      ),
                      CollectionStateWidget(
                        comicId: widget.comicId,
                      ),
                      profileActionWidget(),
                      profileBody(),
                      ProfileContentPreview(
                        profile: widget.profile,
                        comicId: widget.comicId,
                      )
                      // (profile.altTitles != null)
                      //     ? alternativeTitles()
                      //     : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget profileHeader(Comic comic) => Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.h, left: 10.w),
            width: 180.h,
            height: 250.h,
            child: SoupImage(
              url: widget.profile.thumbnail,
              referer: comic.referer,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            child: Container(
              // height: 220.h,
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.only(top: 10.h),
//                                          color: Colors.white12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SelectableText(
                    widget.profile.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                      fontFamily: 'Lato',
                    ),
                    // maxLines: 3,
                  ),
                  Divider(
                    height: 20.h,
                    indent: 5.w,
                    endIndent: 5.w,
                    color: Colors.white12,
                    thickness: 2,
                  ),
                  FittedBox(
                    child: Text(
                        "By ${widget.profile.author.toString().replaceAll("[", "").replaceAll("]", '')}",
                        style: def),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  FittedBox(
                    child: Text(
                      widget.profile.status,
                      style: TextStyle(
                        color: (widget.profile.status
                                .toLowerCase()
                                .contains("complete"))
                            ? Colors.green
                            : (widget.profile.status
                                    .toLowerCase()
                                    .contains("on"))
                                ? Colors.blue
                                : Colors.redAccent,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    "Art by " +
                        widget.profile.artist
                            .toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ''),
                    style: def,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  FittedBox(
                    child: Text(
                      "Source: " + widget.profile.source,
                      style: def,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget actionButton(IconData icon, String actionText, Function action) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.purpleAccent,
          ),
          iconSize: 30.w,
          onPressed: () => action,
        ),
        Text(
          actionText,
          textAlign: TextAlign.center,
          style: def,
        )
      ],
    );
  }

  profileActionWidget() {
    List idk = List();
    if (!widget.profile.containsBooks){
      idk = widget.profile.chapters
          .map((e) => e.generatedNumber)
          .toSet()
          .toList();
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          // Spacer(),
          actionButton(CupertinoIcons.play, "Read", null),
          Spacer(),
          actionButton(
              widget.profile.containsBooks ?CupertinoIcons.collections  :CupertinoIcons.book ,
              widget.profile.containsBooks
                  ? "${widget.profile.bookCount} ${widget.profile.bookCount > 1 ? "Books" : "Book"}"
                  : "${idk.length} ${idk.length > 1 || idk.length == 0 ? "Chapters" : "Chapter"}",
              null),
          Spacer(),
          actionButton(CupertinoIcons.bookmark, "Bookmarks", null),
          Spacer(),
          actionButton(CupertinoIcons.chart_bar_square, "Rate", null),
          // Spacer()
        ],
      ),
    );
  }

  Widget profileBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text(
                  'Description',
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                ),
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(
                        color: Colors.purple,
                        width: 1,
                        style: BorderStyle.solid),
                  ),
                  child: Text(
                    isExpanded ? "▲ Less" : "▼ More",
                    style: TextStyle(color: Colors.purple, fontFamily: "lato"),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),

            Column(
              children: <Widget>[
                ConstrainedBox(
                  constraints: isExpanded
                      ? BoxConstraints()
                      : BoxConstraints(maxHeight: 50.0.h),
                  child: Text(
                    widget.profile.description,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'Genres',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            SizedBox(
              height: 5.h,
            ),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1.7,
                ),
                itemCount: widget.profile.genres.length,
                itemBuilder: (BuildContext context, int index) {
                  Tag tag = widget.profile.genres[index];
                  return TagWidget(
                    tag: tag,
                  );
                }),
            // SizedBox(
            //   height: 10.h,
            // ),
          ],
        ),
      ),
    );
  }
}
