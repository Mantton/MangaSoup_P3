import 'package:flutter/material.dart';

InputDecoration testTextField = InputDecoration(
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
);

final createCollectionFormDecoration = InputDecoration(
  hintText: "Enter Collection Name",
  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey[800]),
    gapPadding: 5,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey[600]),
    gapPadding: 5,
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.red),
    gapPadding: 5,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.redAccent),
    gapPadding: 5,
  ),
  errorStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.bold, fontSize: 15),
  errorMaxLines: 2,
);
