import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/dialogs/library_dialog.dart';

collectionEditDialog({@required BuildContext context, Collection collection}) {
  showGeneralDialog(
    barrierLabel: "Rename this Collection",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => collectionEditBuilder(context, collection),
  );
}

collectionEditBuilder(BuildContext context, Collection collection) {
  String newName;
  return Dialog(
    backgroundColor: Colors.grey[900], //blue for testing, change to black
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: CreateCollectionWidget(
      rename: true,
      toRename: collection,
    ),
  );
}
