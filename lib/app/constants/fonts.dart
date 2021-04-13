import 'dart:ui';

import 'package:flutter/material.dart';

TextStyle def =
    TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Lato");

TextStyle notInLibraryFont = TextStyle(fontSize: 20, fontFamily: "Lato");
TextStyle updateFont = TextStyle(
  fontSize: 15,
  fontFamily: "Lato",
  fontWeight: FontWeight.bold,
  shadows: <Shadow>[
    Shadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 3.0,
      color: Colors.black54,
    ),
    Shadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 3.0,
      color: Colors.black54,
    )
  ],
);

final textFieldStyle = TextStyle(
  height: 1.7,
  color: Colors.grey,
  fontSize: 18,
);
TextStyle isEmptyFont = TextStyle(fontSize: 20, fontFamily: "Lato");

final createCancelStyle = TextStyle(
    fontSize: 20,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    fontFamily: "roboto");
