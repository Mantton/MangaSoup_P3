import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/dialogs/not_in_library.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewProfileScreen extends StatefulWidget {
  final ComicProfile profile;
  final int comicId;

  const NewProfileScreen({Key key, this.profile, this.comicId})
      : super(key: key);

  @override
  _NewProfileScreenState createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen> {
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
                      collectionViewer(comic),
                      ElevatedButton(
                          onPressed: () {
                            int x = Provider.of<DatabaseProvider>(context,
                                    listen: false)
                                .collections
                                .length;
                            print(x);
                          },
                          child: Text("get collections"))
                      // comicActions(),
                      // profileBody(),
                      // contentPreview(),
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

  Widget collectionViewer(Comic comic) => Container(
        child: comic.inLibrary ? inLibrary(comic) : notInLibrary(comic),
      );

  Widget inLibrary(Comic comic) => InkWell(
        onTap: () => notInLibraryDialog(context: context, comicId: comic.id),
        child: Container(
          margin: EdgeInsets.only(left: 10.w),
          height: 50.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_add_check,
                  color: Colors.purple,
                  size: 35,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  "In Library",
                  style: notInLibraryFont,
                ),
                Spacer(),
                Text(
                  "Tap to Edit",
                  style: TextStyle(color: Colors.grey[700], fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      );
  Widget notInLibrary(Comic comic) => InkWell(
        onTap: () => notInLibraryDialog(context: context, comicId: comic.id),
        child: Container(
          margin: EdgeInsets.only(left: 10),
          height: 50.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_add_sharp,
                  color: Colors.purple,
                  size: 35,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  "Add to Library",
                  style: notInLibraryFont,
                ),
              ],
            ),
          ),
        ),
      );
}
