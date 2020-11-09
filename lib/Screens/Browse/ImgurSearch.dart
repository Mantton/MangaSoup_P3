import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Globals.dart';

class ImgurAlbumPage extends StatefulWidget {
  @override
  _ImgurAlbumPageState createState() => _ImgurAlbumPageState();
}

class _ImgurAlbumPageState extends State<ImgurAlbumPage> {
  ApiManager _manager = ApiManager();
  String _info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Imgur Album Search"),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: TextField(
                decoration: msTextField,
                cursorColor: Colors.grey,
                maxLines: 1,
                style: TextStyle(
                  height: 1.7,
                  color: Colors.grey,
                  fontSize: 18,
                ),
                onChanged: (value) async {
                  setState(() {
                    _info = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
              child: CupertinoButton.filled(
                  child: Text("Find"),
                  onPressed: () async {
                    List images = await _manager.getImgurAlbum(_info);
                    if (images.isNotEmpty) {
                      // todo , push to reader
                    } else {
                      showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                                title: Text("Error"),
                                content: Text(
                                    "No Images / Album found in the given address"),
                                actions: [
                                  PlatformDialogAction(
                                    child: Text("OK"),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ));
                    }
                  }),
            )
          ],
        ));
  }
}