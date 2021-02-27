import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/nhentai_property.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/tag_widget.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
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
    fontSize: 15,
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
                    height: 5,
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
          margin: EdgeInsets.only(top: 10, left: 10),
          width: 200,
          height: 300,
          child: SoupImage(
            url: widget.profile.thumbnail,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 10),
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
                    fontSize: 20,
                  ),
                  // maxLines: 2,
                ),
                Divider(
                  height: 20,
                  indent: 5,
                  endIndent: 5,
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
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FittedBox(
                  child: Text(
                    widget.profile.source,
                    style: def,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FittedBox(
                  child: Text(
                    "${widget.profile.pageCount} pages",
                    style: def,
                  ),
                ),
                SizedBox(
                  height: 10,
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
                    left: 15,
                    right: 15,
                  ),
                  margin: EdgeInsets.only(bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5.w.toInt(),
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
            fontSize: 25,
          ),
        ),
        Divider(
          height: 20,
          indent: 5,
          endIndent: 5,
          color: Colors.white12,
          thickness: 2,
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
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
                        Radius.circular(10.0),
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
      Consumer<DatabaseProvider>(builder: (context, provider, _) {
        return GestureDetector(
          onTap: () {
            ImageChapter imageChapter = ImageChapter(
              images: (widget.profile.images),
              referer: widget.profile.link,
              link: widget.profile.link,
              source: widget.profile.selector,
              count: widget.profile.images.length,
            );

            Chapter chapter = Chapter(
                "Chapter 1", widget.profile.link, "", widget.profile.source);
            chapter.generatedNumber = 1.0;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReaderHome(
                  chapters: [chapter],
                  initialChapterIndex: 0,
                  selector: widget.profile.selector ?? widget.profile.source,
                  source: widget.profile.source,
                  comicId: widget.comicId,
                  preloaded: true,
                  preloadedChapter: imageChapter,
                ),
                fullscreenDialog: true,
              ),
            );
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
}
