import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/dialogs/comic_rating.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_bookmarks.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/tag_widget.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/widgets/content_preview.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';
import 'package:provider/provider.dart';

class GenericProfilePage extends StatefulWidget {
  final Profile profile;
  final int comicId;

  const GenericProfilePage({Key key, this.profile, this.comicId})
      : super(key: key);

  @override
  _GenericProfilePageState createState() => _GenericProfilePageState();
}

class _GenericProfilePageState extends State<GenericProfilePage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          // read chapters
          Comic comic = provider.retrieveComic(widget.comicId);
          return homeView(comic: comic);
        },
      ),
    );
  }

  Widget homeView({@required Comic comic}) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      profileHeader(comic),
                      Divider(
                        height: 5,
                        indent: 5,
                        endIndent: 5,
                        color: Colors.white12,
                        thickness: 2,
                      ),
                      CollectionStateWidget(
                        comicId: widget.comicId,
                      ),
                      profileActionWidget(comic),
                      profileBody(),
                      ProfileContentPreview(
                        profile: widget.profile,
                        comicId: widget.comicId,
                        history: Provider.of<DatabaseProvider>(context)
                            .historyList
                            .firstWhere(
                                (element) => element.comicId == widget.comicId,
                                orElse: () => null),
                      )
                      // (profile.altTitles != null)
                      //     ? alternativeTitles()
                      //     : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget profileHeader(Comic comic) => Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, left: 10),
            width: 200,
            height: 300,
            child: SoupImage(
              url: widget.profile.thumbnail,
              referer: comic.referer,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              // height: 220.h,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
//                                          color: Colors.white12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SelectableText(
                    widget.profile.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Lato',
                    ),
                    // maxLines: 3,
                  ),
                  Divider(
                    height: 20,
                    indent: 5,
                    endIndent: 5,
                    color: Colors.white12,
                    thickness: 2,
                  ),
                  FittedBox(
                    child: Text(
                        "By ${widget.profile.author.toString().replaceAll("[", "").replaceAll("]", '')}",
                        style: def),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FittedBox(
                    child: Text(
                      widget.profile.status,
                      style: TextStyle(
                        color: (widget.profile.status
                                .toLowerCase()
                                .contains("complete"))
                            ? Colors.green
                            : (widget.profile.status
                                    .toLowerCase()
                                    .contains("on"))
                                ? Colors.blue
                                : Colors.redAccent,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Art by " +
                        widget.profile.artist
                            .toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ''),
                    style: def,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FittedBox(
                    child: Text(
                      "Source: " + widget.profile.source,
                      style: def,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget actionButton(IconData icon, String actionText, Function action) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.purpleAccent,
          ),
          iconSize: 30,
          onPressed: () => action,
        ),
        Text(
          actionText,
          textAlign: TextAlign.center,
          style: def,
        )
      ],
    );
  }

  profileActionWidget(Comic comic) {
    List idk = List();
    if (!widget.profile.containsBooks) {
      idk = widget.profile.chapters
          .map((e) => e.generatedNumber)
          .toSet()
          .toList();
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          // Spacer(),
          Consumer<DatabaseProvider>(
              builder: (BuildContext context, provider, _) {
            History comicHistory;
            try {
              comicHistory = provider.historyList
                  .firstWhere((element) => element.comicId == widget.comicId);
            } catch (err) {
              // Comic Has No History
            }
            bool exists = (comicHistory != null) ? true : false;
            return InkWell(
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.play,
                      color: Colors.purpleAccent,
                    ),
                    iconSize: 30,
                    onPressed: () => playContinueLogic(comicHistory),
                  ),
                  Text(
                    exists ? "Continue" : "Read",
                    textAlign: TextAlign.center,
                    style: def,
                  ),
                ],
              ),
            );
          }),
          Spacer(),
          actionButton(
              widget.profile.containsBooks
                  ? CupertinoIcons.collections
                  : CupertinoIcons.book,
              widget.profile.containsBooks
                  ? "${widget.profile.bookCount} ${widget.profile.bookCount > 1 ? "Books" : "Book"}"
                  : "${idk.length} ${idk.length > 1 || idk.length == 0 ? "Chapters" : "Chapter"}",
              null),
          Spacer(),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.bookmark,
                  color: Colors.purpleAccent,
                ),
                iconSize: 30,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComicBookMarksPage(
                      comicId: widget.comicId,
                      profile: widget.profile,
                    ),
                  ),
                ),
              ),
              Text(
                "Bookmarks",
                textAlign: TextAlign.center,
                style: def,
              )
            ],
          ),
          Spacer(),

          comic.rating == 0
              ? Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chart_bar_square,
                        color: Colors.purpleAccent,
                      ),
                      iconSize: 30,
                      onPressed: () =>
                          comicRatingDialog(context: context, comic: comic),
                    ),
                    Text(
                      "Rate",
                      textAlign: TextAlign.center,
                      style: def,
                    )
                  ],
                )
              : InkWell(
                  onTap: () =>
                      comicRatingDialog(context: context, comic: comic),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${comic.rating}/5",
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Rating",
                        textAlign: TextAlign.center,
                        style: def,
                      )
                    ],
                  ),
                ),
          // Spacer()
        ],
      ),
    );
  }

  playContinueLogic(History history) {
    if (history != null) {
      // Continue
      ChapterData pointer =
          Provider.of<DatabaseProvider>(context, listen: false)
              .chapters
              .firstWhere((element) => element.id == history.chapterId);
      int target = widget.profile.chapters
          .indexWhere((element) => element.link == pointer.link);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderHome(
            selector: widget.profile.selector,
            chapters: widget.profile.chapters,
            initialChapterIndex: target,
            comicId: widget.comicId,
            source: widget.profile.source,
            initialPage: pointer.lastPageRead,
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      // Start from Chapter 1
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderHome(
            selector: widget.profile.selector,
            chapters: widget.profile.chapters,
            initialChapterIndex:
                widget.profile.chapters.indexOf(widget.profile.chapters.last),
            comicId: widget.comicId,
            source: widget.profile.source,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget profileBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text(
                  'Description',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(
                        color: Colors.purple,
                        width: 1,
                        style: BorderStyle.solid),
                  ),
                  child: Text(
                    isExpanded ? "▲ Less" : "▼ More",
                    style: TextStyle(color: Colors.purple, fontFamily: "lato"),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),

            Column(
              children: <Widget>[
                ConstrainedBox(
                  constraints: isExpanded
                      ? BoxConstraints()
                      : BoxConstraints(maxHeight: 50.0),
                  child: Text(
                    widget.profile.description +
                        "\nALTERNATE TITLES: ${widget.profile.altTitles.toString()}",
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Genres',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            SizedBox(
              height: 5,
            ),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5.w.toInt(),
                  crossAxisSpacing: 0,
                  childAspectRatio: 1.7,
                ),
                itemCount: widget.profile.genres.length,
                itemBuilder: (BuildContext context, int index) {
                  Tag tag = widget.profile.genres[index];
                  return TagWidget(
                    tag: tag,
                  );
                }),
            // SizedBox(
            //   height: 10.h,
            // ),
          ],
        ),
      ),
    );
  }
}
