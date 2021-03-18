import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/profile/profile_home.dart';
import 'package:provider/provider.dart';

import 'HighlightGrid.dart';
import 'Images.dart';

class ComicList extends StatefulWidget {
  final List<ComicHighlight> comics;
  final int crossAxisCount;

  const ComicList({Key key, @required this.comics, this.crossAxisCount})
      : super(key: key);

  @override
  _ComicListState createState() => _ComicListState();
}

class _ComicListState extends State<ComicList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: Consumer<PreferenceProvider>(builder: (context, settings, _) {
        return ListView.separated(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.comics.length,
          itemBuilder: (BuildContext context, index) => ComicListTile(
            comic: widget.comics[index],
          ),
          separatorBuilder: (_, index) => SizedBox(
            height: 4,
          ),
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ComicListTile extends StatelessWidget {
  final ComicHighlight comic;

  const ComicListTile({Key key, @required this.comic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Color.fromRGBO(8, 8, 8, 1.0),
      leading: FittedBox(
        child: SoupImage(
          url: comic.thumbnail,
          referer: comic.imageReferer,
          // fit: BoxFit.fitWidth,
        ),
      ),
      onTap: () {
        debugPrint("${comic.title} @ ${comic.link} /f ${comic.source}");
        Navigator.push(
          context,
          MaterialPageRoute(
            maintainState: true,
            builder: (_) => ProfileHome(highlight: comic),
          ),
        );
      },
      subtitle: Text(
        comic.source,
        style: TextStyle(color: Colors.grey[700]),
      ),
      title: AutoSizeText(
        comic.title,
        style: TextStyle(
          fontFamily: "Lato",
          color: Colors.white,
          // fontSize: 17,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 7.0,
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 3.0,
              color: Colors.black,
            )
          ],
        ),
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 2,
        presetFontSizes: [17, 15],
      ),
      trailing: FittedBox(child: GridHeader(comic: comic)),
    );
  }
}
