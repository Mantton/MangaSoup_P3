import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

StreamController<String> sourcesStream = StreamController.broadcast();
StreamController<String> favoritesStream = StreamController.broadcast();
StreamController<String> historyStream = StreamController.broadcast();

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
