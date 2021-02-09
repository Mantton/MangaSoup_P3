import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/dialogs/library_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
class CollectionStateWidget extends StatefulWidget {
  final int comicId;

  const CollectionStateWidget({Key key, @required this.comicId}) : super(key: key);
  @override
  _CollectionStateWidgetState createState() => _CollectionStateWidgetState();
}

class _CollectionStateWidgetState extends State<CollectionStateWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (BuildContext context, provider, _) =>
          collectionViewer(
              provider.retrieveComic(widget.comicId)),
    );
  }

  Widget collectionViewer(Comic comic) => Container(
    child: comic.inLibrary ? inLibrary(comic) : notInLibrary(comic),
  );

  Widget inLibrary(Comic comic) => InkWell(
    onTap: () => libraryDialog(context: context, comicId: comic.id),
    child: Container(
      margin: EdgeInsets.only(left: 10.w),
      height: 50.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.checkmark_seal,
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
    onTap: () => libraryDialog(context: context, comicId: comic.id),
    child: Container(
      margin: EdgeInsets.only(left: 10),
      height: 50.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.folder_badge_plus,
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
