import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/enums/comic_status.dart';
import 'package:mangasoup_prototype_3/app/dialogs/comic_rating.dart';
import 'package:mangasoup_prototype_3/app/screens/migrate/migrate_select_source.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_bookmarks.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/tabs/profile_detail/widgets/tag_widget.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/widgets/content_preview.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_home.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';
import 'package:provider/provider.dart';

import 'all_chapters.dart';

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
          padding: EdgeInsets.all(2.0),
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
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.profile.title));
                      showSnackBarMessage("Copied title to clipboard!");
                    },
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
                      statusNames[widget.profile.status.index],
                      style: TextStyle(
                        color: statusColors[widget.profile.status.index],
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

  profileActionWidget(Comic comic) {
    List idk = [];
    idk =
        widget.profile.chapters.map((e) => e.generatedNumber).toSet().toList();

    return Container(
      padding: EdgeInsets.all(3),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Spacer(),
          Expanded(
            child: Consumer<DatabaseProvider>(
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
                onTap: () => playContinueLogic(comicHistory),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.play,
                      color: Colors.purpleAccent,
                      size: 27,
                    ),
                    Text(
                      exists ? "Continue\n" : "Read\n",
                      textAlign: TextAlign.center,
                      style: def,
                    ),
                  ],
                ),
              );
            }),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterList(
                    chapterList: widget.profile.chapters,
                    comicId: widget.comicId,
                    selector: widget.profile.selector,
                    source: widget.profile.source,
                    profile: widget.profile,
                    history: Provider.of<DatabaseProvider>(context)
                        .historyList
                        .firstWhere(
                            (element) => element.comicId == widget.comicId,
                            orElse: () => null),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.book,
                    color: Colors.purpleAccent,
                    size: 27,
                  ),
                  Text(
                    "${idk.length}\n",
                    // ${idk.length > 1 || idk.length == 0 ? "Chapters" : "Chapter"}
                    textAlign: TextAlign.center,
                    style: def,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComicBookMarksPage(
                    comicId: widget.comicId,
                    profile: widget.profile,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.bookmark,
                    color: Colors.purpleAccent,
                    size: 27,
                  ),
                  Text(
                    "Bookmarks\n",
                    textAlign: TextAlign.center,
                    style: def,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ratings(comic),
          ),
          comic.inLibrary
              ? Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MigrateSourceSelector(
                          comic: comic,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_up_bin,
                          color: Colors.purpleAccent,
                          size: 27,
                        ),
                        Text(
                          "Migrate\n",
                          textAlign: TextAlign.center,
                          style: def,
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          // Spacer()
        ],
      ),
    );
  }

  playContinueLogic(History history) {
    try {
      if (history != null) {
        // Continue
        ChapterData pointer =
            Provider.of<DatabaseProvider>(context, listen: false)
                .chapters
                .firstWhere((element) => element.id == history.chapterId);
        int target = widget.profile.chapters
            .indexWhere((element) => element.link == pointer.link);
        if (target < 0) {
          Provider.of<DatabaseProvider>(context, listen: false)
              .removeHistory(history)
              .then((value) => throw "Bad State, No Pointer");
        }

        if (widget.profile.chapters[target] != widget.profile.chapters.first &&
            (pointer.lastPageRead == pointer.images.length)) {
          // Open Next Chapter
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderHome(
                selector: widget.profile.selector,
                chapters: widget.profile.chapters,
                initialChapterIndex:
                    getTarget(widget.profile.chapters, pointer, target),
                comicId: widget.comicId,
                source: widget.profile.source,
                initialPage: 1,
              ),
              fullscreenDialog: true,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderHome(
                selector: widget.profile.selector,
                chapters: widget.profile.chapters,
                initialChapterIndex: target,
                comicId: widget.comicId,
                source: widget.profile.source,
                initialPage: (pointer.lastPageRead == pointer.images.length)
                    ? 1
                    : pointer.lastPageRead,
              ),
              fullscreenDialog: true,
            ),
          );
        }
      } else {
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
    } catch (err) {
      showSnackBarMessage(err.toString(), error: true);
    }
  }

  int getTarget(List<Chapter> chapters, ChapterData pointer, int index) {
    if (index > 0) {
      if (chapters[index - 1].generatedNumber == pointer.generatedChapterNumber)
        return getTarget(chapters, pointer, index - 1);
      else
        return index - 1;
    } else
      return index;
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
            widget.profile.genres.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                    ],
                  )
                : Container(),
            // SizedBox(
            //   height: 10.h,
            // ),
          ],
        ),
      ),
    );
  }

  Widget ratings(Comic comic) {
    return comic.rating == 0
        ? InkWell(
            onTap: () => comicRatingDialog(context: context, comic: comic),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.chart_bar_square,
                  color: Colors.purpleAccent,
                  size: 27,
                ),
                Text(
                  "Rate\n",
                  textAlign: TextAlign.center,
                  style: def,
                )
              ],
            ),
          )
        : Column(
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
          );
  }
}
