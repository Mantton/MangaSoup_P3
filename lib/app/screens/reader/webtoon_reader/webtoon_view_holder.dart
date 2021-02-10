import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/ReaderComponents.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";


import 'package:provider/provider.dart';

import '../reader_provider.dart';class ImageHolder extends StatefulWidget {
  final ReaderPage page;

  const ImageHolder({Key key, this.page}) : super(key: key);
  @override
  _ImageHolderState createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, settings, _) {
        return GestureDetector(
          onTap: ()=>Provider.of<ReaderProvider>(context, listen: false).toggleShowControls(),
          child: Padding(
            padding:  EdgeInsets.all(
             settings .readerMode == 1? settings.readerPadding ? 10.w : 0.0: 0.0,
            ),
            child: VioletImage(
              url: widget.page.imgUrl,
              referrer: widget.page.referer,
            ),
          ),
        );
      }
    );
  }
}
