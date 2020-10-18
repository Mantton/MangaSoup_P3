import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';

class SourceNotifier extends ChangeNotifier {
  Source source;

  setSource(Source src) async {
    source = src;
    notifyListeners();
  }

  loadSource(Source src) async {
    source = src;
  }
}
