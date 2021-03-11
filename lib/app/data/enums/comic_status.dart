import 'package:flutter/material.dart';

enum Status {
  unknown,
  ongoing,
  completed,
  cancelled,
  hiatus,
  scanning,
}

List statusNames = [
  "Unknown",
  "Ongoing",
  "Completed",
  "Cancelled",
  "Hiatus",
  "Scanlating",
];

List statusColors = [
  Colors.red[900],
  Colors.blue,
  Colors.green,
  Colors.redAccent,
  Colors.amber,
  Colors.indigoAccent
];
