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
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: AddCollection(
      collectionID: collection.id,
      rename: true,
    ),
  );
}

collectionAddDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Rename this Collection",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => collectionAddBuilder(),
  );
}

collectionAddBuilder() {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: AddCollection(
      dialog: true,
    ),
  );
}
