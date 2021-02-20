import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';

class EmptyResponsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Text(
            "An Error Occurred\nMangaSoup returned no images with a successful"
            " response, contact devs for help\nTap to close reader",
            style: notInLibraryFont,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
