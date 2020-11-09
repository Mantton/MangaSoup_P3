import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/GateWay.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';

class ImageSearchPage extends StatefulWidget {
  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  File _image;
  final picker = ImagePicker();
  Future<List<ImageSearchResult>> results;
  ApiManager _manager = ApiManager();
  TextStyle def = TextStyle(fontSize: 18.sp, fontFamily: "Lato");
  TextStyle chapterTitleFont = TextStyle(fontSize: 21.sp, fontFamily: "Lato");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Search"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0.w),
          child: Column(
            children: [
              submitImage(),
              SizedBox(
                height: 10.h,
              ),
              resultsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget submitImage() {
    return Container(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                child: InkWell(
                  child: Text(
                    'Choose an Image',
                    style: def,
                  ),
                ),
              ),
              Spacer(),
              InkWell(
                onTap: getImage,
                child: Container(
                  height: 150.h,
                  width: 100.w,
                  color: Colors.grey[900],
                  child: _image == null
                      ? Container(
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.grey,
                              size: 100,
                            ),
                          ),
                        )
                      : Image.file(_image),
                ),
              ),
            ],
          ),
          SizedBox(

            height: 15.h,
          ),
          Center(
            child: Container(
              child: CupertinoButton.filled(
                onPressed: _image == null
                    ? null
                    : () async {

                        setState(() {
                          results = _manager.imageSearch(_image);

                          /// Image Search
                          /// g
                        });
                      },
                child: Text(
                  'Search',
                  style: def,
                ),
                disabledColor: Colors.grey[900],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future getImage() async {
    if (_image != null) _image = null;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      results = _manager.imageSearch(_image);
    });
  }

  Widget resultsWidget() {
    return Container(
      child: FutureBuilder(
        future: results,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    results = _manager.imageSearch(_image);
                  });
                },
                child: Text(
                  "An Error Occurred \n ${snapshot.error} \n Tap to Retry",
                  style: chapterTitleFont,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            List<ImageSearchResult> _res = snapshot.data;
            return (_res.isEmpty)
                ? Container(
                    child: Center(
                      child: Text(
                        "No Results",
                        style: chapterTitleFont,
                      ),
                    ),
                  )
                : Container(
                    child: ListView.builder(
                        itemCount: _res.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          ImageSearchResult searchResult = _res[index];
                          return Container(
                            color: Colors.grey[900],
                            margin: EdgeInsets.only(
                              bottom: 25.h,
                            ),
                            padding: EdgeInsets.all(
                              10.w,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      fit: FlexFit.loose,
                                      flex: 2,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              searchResult.title,
                                              softWrap: true,
                                              style: chapterTitleFont,
                                            ),
                                            Text(
                                              searchResult.chapter,
                                              style: def,
                                            ),
                                            Text(
                                              "${searchResult.similarity}% Match",
                                              style: def,
                                            ),
                                            Text(
                                              "Written by ${searchResult.author}",
                                              style: def,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Flexible(
                                      child: Container(
                                        height: 150,
                                        width: 100,
                                        child: SoupImage(
                                          url: searchResult.thumbnail,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Row(
                                  children: [
                                    CupertinoButton(
                                      child: Text(
                                        "Read Chapter",
                                        style: chapterTitleFont,
                                      ),
                                      onPressed: () {
                                        // todo, get profile link then push to reader
                                      },
                                    ),
                                    Spacer(),
                                    CupertinoButton(
                                        child: Text(
                                          "View Comic",
                                          style: chapterTitleFont,
                                        ),
                                        onPressed: () async {
                                          showLoadingDialog(context);
                                          DexHub _dex = DexHub();
                                          ComicHighlight comicHighlight =
                                              await _dex.imageSearchViewComic(
                                                  searchResult.mCID);
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProfileGateWay(
                                                comicHighlight,
                                              ),
                                            ),
                                          );
                                        })
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                  );
          } else {
            return Container(
              height: 300.h,
              child: Center(
                child: Text(
                  "Awaiting the Image",
                  style: def,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
