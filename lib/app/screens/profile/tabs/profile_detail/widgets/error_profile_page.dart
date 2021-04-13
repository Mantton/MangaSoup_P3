import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/migrate/migrate_select_source.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';
import 'package:provider/provider.dart';

class ErrorProfilePage extends StatefulWidget {
  final error;
  final ComicHighlight highlight;

  const ErrorProfilePage(
      {Key key, @required this.error, @required this.highlight})
      : super(key: key);

  @override
  _ErrorProfilePageState createState() => _ErrorProfilePageState();
}

class _ErrorProfilePageState extends State<ErrorProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, _) {
        // read chapters
        Comic comic = provider.nullableRetrieveComic(widget.highlight);
        return Center(child: home(comic));
      },
    );
  }

  Widget home(Comic comic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          child: Text(
            "An Error Occurred\n ${widget.error.toString()}\n Tap to go back home",
            textAlign: TextAlign.center,
            style: notInLibraryFont,
          ),
          onTap: () => Navigator.pop(context),
        ),
        comic != null ? offlineOptions(comic) : Container()
      ],
    );
  }

  Widget offlineOptions(Comic comic) {
    return Column(
      children: [
        CollectionStateWidget(
          comicId: comic.id,
        ),
        CupertinoButton(
          child: Text("Migrate"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MigrateSourceSelector(
                comic: comic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
