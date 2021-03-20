import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/widgets/comic_collection_widget.dart';

class ReachedEndPage extends StatelessWidget {
  final Comic inLibrary;

  const ReachedEndPage({Key key, this.inLibrary}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .85,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reached End.\n"
              "${inLibrary.inLibrary ? "In your library, you will be notified when a new chapter is available" : "Add this comic to your library to be updated when more chapters are released!"}",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: "Lato",
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: CollectionStateWidget(
                comicId: inLibrary.id,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              height: 60,
              minWidth: 120,
              onPressed: () {
                // Provider.of<PreferenceProvider>(context, listen: false)
                //     .setReaderMode(1);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.grey[900])),
              color: Colors.grey[900],
              child: Text(
                "Exit",
                style: notInLibraryFont,
              ),
            )
          ],
        ),
        // add button
        // recommendations
      ),
    );
  }
}
