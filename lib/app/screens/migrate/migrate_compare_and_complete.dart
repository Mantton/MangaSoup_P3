import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/migrate_provider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

class MigrateCompare extends StatefulWidget {
  final Comic current;
  final ComicHighlight destination;

  const MigrateCompare(
      {Key key, @required this.current, @required this.destination})
      : super(key: key);

  @override
  _MigrateCompareState createState() => _MigrateCompareState();
}

class _MigrateCompareState extends State<MigrateCompare> {
  @override
  void initState() {
    Provider.of<MigrateProvider>(context, listen: false).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compare"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ComicInformation(
                        comic: widget.current.toHighlight(),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.arrow_right_circle,
                      color: Colors.green,
                    ),
                    Expanded(
                      flex: 5,
                      child: ComicInformation(
                        comic: widget.destination,
                        isDestination: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.all(3),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.amber,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        "The Unique Chapter Count displayed may not be 100% "
                        "accurate as it is detected programmatically.",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Lato",
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Consumer<MigrateProvider>(builder: (context, provider, _) {
                return CupertinoButton.filled(
                  child: Text(
                    "Migrate",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: provider.canMigrate
                      ? () {
                          // pop to home, push to profile
                        }
                      : null,
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

class ComicInformation extends StatefulWidget {
  final ComicHighlight comic;
  final bool isDestination;

  const ComicInformation({
    Key key,
    @required this.comic,
    this.isDestination = false,
  }) : super(key: key);

  @override
  _ComicInformationState createState() => _ComicInformationState();
}

class _ComicInformationState extends State<ComicInformation> {
  Future<Profile> p;

  @override
  void initState() {
    p = getProfile();
    super.initState();
  }

  Future<Profile> getProfile() async {
    Profile y =
        await ApiManager().getProfile(widget.comic.selector, widget.comic.link);
    Provider.of<MigrateProvider>(context, listen: false)
        .setProfile(y, widget.isDestination);

    return y;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: p,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
              child: Center(
                child: LoadingIndicator(),
              ),
            );
          else if (snapshot.hasError)
            return Container(
              child: Center(
                child: Text(
                  "${snapshot.error}",
                  style: notInLibraryFont,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          else if (!snapshot.hasData)
            return Container(
              child: Center(
                child: Text(
                  "Critical Error\nYou should not be seeing this",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          else
            return InfoPane(
              profile: snapshot.data,
            );
        });
  }
}

class InfoPane extends StatelessWidget {
  final Profile profile;

  const InfoPane({Key key, @required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            profile.title,
            style: notInLibraryFont,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            profile.source,
            style: TextStyle(
              fontSize: 15,
              fontFamily: "Lato",
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          (profile.chapters != null && profile.chapters.isNotEmpty)
              ? Column(
                  children: [
                    Text(
                      "${profile.chapterCount} Total Chapter(s)",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Lato",
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "${profile.chapters.map((e) => e.generatedNumber).toSet().toList().length} Unique Chapter(s) Detected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: "Lato",
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    "No Chapters",
                  ),
                ),
        ],
      ),
    );
  }
}
