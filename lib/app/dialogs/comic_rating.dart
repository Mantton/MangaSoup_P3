import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

comicRatingDialog({@required BuildContext context,Comic comic}) {
  showGeneralDialog(
    barrierLabel: "Rate This Comic",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => ratingBuilder(context, comic),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

ratingBuilder(BuildContext context, Comic comic) => Dialog(
      backgroundColor: Colors.grey[900], //blue for testing, change to black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate",
              style: notInLibraryFont,
            ),
            // SizedBox(
            //   height: 10.h,
            // ),
            Container(
              height: 75.h,
              child: Center(
                child: RatingBar.builder(
                  initialRating: comic.rating.toDouble() != 0? comic.rating.toDouble(): 1.0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.purple,
                  ),
                  glow: false,
                  onRatingUpdate: (rating) {
                    comic.rating = rating.toInt();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                Spacer(),
                InkWell(
                  child: Text(
                    "Cancel",
                    style: createCancelStyle,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                Spacer(),
                Spacer(),
                InkWell(
                  child: Text(
                    "Confirm",
                    style: createCancelStyle,
                  ),
                  onTap: (){
                    if (comic.rating == 0)
                      comic.rating =1 ;
                    Provider.of<DatabaseProvider>(context, listen: false).evaluate(comic);
                    Navigator.pop(context);
                  },
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
