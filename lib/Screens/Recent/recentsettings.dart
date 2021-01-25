import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
showSettings({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "History Settings",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => buildFilters(context),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

buildFilters(context) => Dialog(
  backgroundColor: Colors.black87,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
  ),
  child: Container(
    height: 500.h,
    child: Padding(
      padding: EdgeInsets.all(17.0.w),
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "History Settings",
                    style: TextStyle(fontFamily: "Roboto", fontSize: 30.sp),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 30.w,
                      color: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    ),
  ),
);

