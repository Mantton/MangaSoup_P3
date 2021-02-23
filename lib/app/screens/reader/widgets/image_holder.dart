import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:provider/provider.dart';

import '../reader_provider.dart';


class ImageHolder extends StatelessWidget {
  final ReaderPage page;

  const ImageHolder({Key key, this.page}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, settings, _) {
        return GestureDetector(
          onTap: ()=>Provider.of<ReaderProvider>(context, listen: false).toggleShowControls(),
          child: Padding(
            padding:  EdgeInsets.all(
             settings .readerMode == 1? settings.readerPadding ? 4 : 0.0: 0.0,
            ),
            child: ReaderImage(
              url: page.imgUrl,
              referer: page.referer,
            ),
          ),
        );
      }
    );
  }
}
