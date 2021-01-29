import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/nhentai_property.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/dialogs/not_in_library.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/tag_widget.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';
import 'package:provider/provider.dart';

class CustomProfilePage extends StatefulWidget {
  final Profile profile;
  final int comicId;

  const CustomProfilePage({Key key, @required this.profile, this.comicId})
      : super(key: key);

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
    return SingleChildScrollView(
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
                    height: 10.h,
                    indent: 5.w,
                    endIndent: 5.w,
                    color: Colors.white12,
                    thickness: 2,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 8.0.w, right: 8.w),
                      child: CollectionStateWidget(
                        comicId: widget.comicId,
                      )),
                  profileTags(),
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
    );
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
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.only(top: 10.h),
//                                          color: Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.profile.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontSize: 20.sp,
                  ),
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

  Widget profileTags() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.profile.properties.length, (index) {
          DescriptionProperty property = widget.profile.properties[index];
          return (property.tags.isNotEmpty)
              ? Container(
                  padding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                  ),
                  margin: EdgeInsets.only(bottom: 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
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
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1.7,
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: property.tags.length,
                        itemBuilder: (BuildContext context, int i) => TagWidget(
                          tag: property.tags[i],
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
      mainAxisSize: MainAxisSize.min,
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

  Widget readButton() =>
      Consumer(builder: (context, provider, _) {
        return GestureDetector(
          onTap: () {
            ComicHighlight highlight = provider.highlight;
            ImageChapter chapter = ImageChapter(
              images: (widget.profile.images)
                  ?.map((item) => item as String)
                  ?.toList(),
              referer: highlight.imageReferer,
              link: widget.profile.link,
              source: highlight.selector,
              count: widget.profile.images.length,
            );

            //todo, push to reader
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => DebugReader2(
            //       selector: highlight.selector,
            //       custom: true,
            //       chapter: chapter,
            //     ),
            //   ),
            // );
          },
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
      });

  Widget collectionViewer(Comic comic) => Container(
        child: comic.inLibrary ? inLibrary(comic) : notInLibrary(comic),
      );

  Widget inLibrary(Comic comic) => InkWell(
        onTap: () => notInLibraryDialog(context: context, comicId: comic.id),
        child: Container(
          margin: EdgeInsets.only(left: 10.w),
          height: 50.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_add_check,
                  color: Colors.purple,
                  size: 35,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  "In Library",
                  style: notInLibraryFont,
                ),
                Spacer(),
                Text(
                  "Tap to Edit",
                  style: TextStyle(color: Colors.grey[700], fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      );
  Widget notInLibrary(Comic comic) => InkWell(
        onTap: () => notInLibraryDialog(context: context, comicId: comic.id),
        child: Container(
          margin: EdgeInsets.only(left: 10),
          height: 50.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_add_sharp,
                  color: Colors.purple,
                  size: 35,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  "Add to Library",
                  style: notInLibraryFont,
                ),
              ],
            ),
          ),
        ),
      );
}
