import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

showMessage(String info, IconData img, Duration duration) {
  BotToast.showEnhancedWidget(
    toastBuilder: (_) => IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          height: 150.h,
          width: 150.w,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    img,
                    color: Colors.white,
                    size: 60.w,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  AutoSizeText(
                    info,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    duration: duration,
  );
}

showSnackBarMessage(String msg){
  BotToast.showText(
      duration: Duration(milliseconds: 1500),
      text: msg,
      textStyle: TextStyle(color: Colors.black),
      contentColor: Colors.white,

  );


}
