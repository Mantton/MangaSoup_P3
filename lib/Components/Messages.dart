import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

showMessage(String info, IconData img, Duration duration) {
  BotToast.showEnhancedWidget(
    toastBuilder: (_) => IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          height: 150,
          width: 150,
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
                    size: 60,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  AutoSizeText(
                    info,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

showSnackBarMessage(String msg, {bool error = false, bool success = false}) {
  BotToast.showText(
    duration: Duration(milliseconds: 1500),
    text: msg,
    textStyle: TextStyle(
        color: !error ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: "Lato"),
    contentColor: !error
        ? success
            ? Colors.green
            : Colors.white
        : Colors.redAccent,
  );
}
