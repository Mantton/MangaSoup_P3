import 'package:flutter/material.dart';

collectionEditDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Rate This Comic",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => collectionEditBuilder(context),
  );
}

collectionEditBuilder(BuildContext context) => Dialog(
      backgroundColor: Colors.grey[900], //blue for testing, change to black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
