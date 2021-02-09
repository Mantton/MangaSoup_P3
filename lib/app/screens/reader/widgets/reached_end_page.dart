import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';

class ReachedEndPage extends StatelessWidget {
  final Comic inLibrary;

  const ReachedEndPage({Key key, this.inLibrary}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "That was the last available chapter.\n"
              "${inLibrary.inLibrary ? "This comic is in your library, you will be notified when a new chapter is available" : "Add this comic to your library to be updated when more chapters are released!"}",
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                fontFamily: "Lato",
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h,),
            Container(
              padding: EdgeInsets.all(8.w),
              child: CollectionStateWidget(
                comicId: inLibrary.id,
              ),
            )
          ],
        ),
        // add button
        // recommendations
      ),
    );
  }
}
