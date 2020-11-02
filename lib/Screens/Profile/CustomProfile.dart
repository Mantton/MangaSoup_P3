import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProfilePage extends StatefulWidget {
  final ComicProfile profile;

  const CustomProfilePage({Key key, @required this.profile}) : super(key: key);

  @override
  _CustomProfilePageState createState() => _CustomProfilePageState();
}

class _CustomProfilePageState extends State<CustomProfilePage> {
  TextStyle def = TextStyle(
    color: Colors.white,
    fontSize: 15.sp,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      profileHeader(),
                      Divider(
                        height: 20.h,
                        indent: 5.w,
                        endIndent: 5.w,
                        color: Colors.white12,
                        thickness: 2,
                      ),
                      profileTags(widget.profile.properties),
                      readButton(),
                      SizedBox(
                        height: 5.h,
                      ),
                      contentPreview()
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget profileHeader() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.h),
          width: 150.h,
          height: 250.h,
          child: SoupImage(url: widget.profile.thumbnail),
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: Container(
            height: 220.h,
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.only(top: 10.h),
//                                          color: Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  widget.profile.title,
                  style: TextStyle(color: Colors.white, fontFamily: 'Lato'),
                  // maxLines: 2,
                ),
                Divider(
                  height: 20.h,
                  indent: 5.w,
                  endIndent: 5.w,
                  color: Colors.white12,
                  thickness: 2,
                ),
                FittedBox(
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.profile.galleryId));
                      showSnackBarMessage("Copied sauce to clipboard!");
                    },
                    child: Text(
                      "#${widget.profile.galleryId ?? ""}",
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    widget.profile.source,
                    style: def,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    "${widget.profile.pageCount} pages",
                    style: def,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    "Uploaded ${widget.profile.uploadDate}",
                    style: def,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profileTags(List properties) {
    return Container(
      child: Column(
        children: List.generate(properties.length, (index) {
          Map property = properties[index];
          String name = property['name'];
          List tags = property['tags'];
          return (tags.isNotEmpty)
              ? Container(
                  padding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                  ),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17.sp,
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.7,
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int i) =>
                            GestureDetector(
                          onTap: null,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Center(
                                child: Text(
                                  tags[i]['tag'],
                                  softWrap: true,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container();
        }),
      ),
    );
  }

  Widget contentPreview() {
    return Column(
      children: [
        Text(
          "Preview",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 25.sp,
          ),
        ),
        Divider(
          height: 20.h,
          indent: 5.w,
          endIndent: 5.w,
          color: Colors.white12,
          thickness: 2,
        ),
        Padding(
          padding: EdgeInsets.all(8.0.w),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20.w,
                mainAxisSpacing: 20.h,
                childAspectRatio: .75,
              ),
              itemCount: (widget.profile.images.length > 6)
                  ? 6
                  : widget.profile.images.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GalleryViewer(
                        images: (widget.profile.images.length > 9)
                            ? widget.profile.images.sublist(1, 9)
                            : widget.profile.images,
                      ),
                    ),
                  ),
                  child: GridTile(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0.w),
                      ),
                      child: Container(
                          child: SoupImage(
                        url: widget.profile.images[index],
                      )),
                    ),
                  ),
                );
              }),
        ),
        SizedBox(
          height: 5,
        ),
        readButton()
      ],
    );
  }

  Widget readButton() => GestureDetector(
        onTap: null,
        child: Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          height: 45,
          child: Center(
            child: Text(
              'Read',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.purple, fontSize: 20),
            ),
          ),
        ),
      );
}
