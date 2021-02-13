import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

StreamController<String> sourcesStream = StreamController.broadcast();
StreamController<String> bgUpdateStream = StreamController.broadcast();
TextStyle isEmptyFont = TextStyle(fontSize: 20, fontFamily: "Lato");

Map<String, String> imageHeaders(String link) {
  if (link.contains("mangahasu"))
    return {"Referer": "http://mangahasu.se"};
  else if (link.contains("mangakakalot"))
    return {"Referer": "https://manganelo.com/"};
  else
    return null;
}

final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your Email";
const String kInvalidEmailError = "Please Enter a Valid Email Address";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";

final InputDecoration msTextField = InputDecoration(
  contentPadding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.grey[800]),
    gapPadding: 5,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.grey[600]),
    gapPadding: 5,
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.red),
    gapPadding: 5,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.redAccent),
    gapPadding: 5,
  ),
  suffixIcon: Icon(
    Icons.search,
    color: Colors.purple,
  ),
);

msDecoration(String hint) {
  return InputDecoration(
    hintText: hint,

    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey[800]),
      gapPadding: 5,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey[600]),
      gapPadding: 5,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.red),
      gapPadding: 5,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.redAccent),
      gapPadding: 5,
    ),
    suffixIcon: Icon(
      Icons.search,
      color: Colors.purple,
    ),
  );
}