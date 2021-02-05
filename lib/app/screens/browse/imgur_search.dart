import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:mangasoup_prototype_3/app/util/generateChapterNumber.dart';
import '../../../Globals.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';

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
                    showLoadingDialog(context);
                    print(_info);
                    Map imgurInfo = await _manager.getImgurAlbum(_info);
                    String title = imgurInfo['title'];
                    List images = imgurInfo['images'];
                    Navigator.pop(context);
                    if (images.isNotEmpty) {
                      ImageChapter imageChapter = ImageChapter(
                        images:
                            (images)?.map((item) => item as String)?.toList(),
                        referer: "https://imgur.com",
                        link: _info.contains("https")
                            ? "$_info"
                            : "https://imgur.com/a/$_info",
                        source: "Imgur",
                        count: images.length,
                      );

                      Chapter chapter =
                          Chapter(title, imgurInfo['link'], "", "imgur");
                      chapter.generatedNumber = ChapterRecognition()
                          .parseChapterNumber(title, "Imgur Album");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderHome(
                            chapters: [chapter],
                            initialChapterIndex: 0,
                            selector: "imgur",
                            source: "Imgur",
                            imgur: true,
                            comicId: null,
                            preloaded: true,
                            preloadedChapter: imageChapter,
                          ),
                        ),
                      );
                    } else {
                      showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                                title: Text("Error"),
                                content: Text(
                                  "No Images / Album found in the given address",
                                ),
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
