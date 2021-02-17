import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/library/libary_order.dart';
import 'package:mangasoup_prototype_3/app/screens/library/library_bulk_delete.dart';
import 'package:mangasoup_prototype_3/app/screens/library/library_migrate.dart';
import 'package:provider/provider.dart';

libraryOptionsDialog({@required BuildContext context, int comicId}) {
  showGeneralDialog(
    barrierLabel: "Not In Library",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => libraryOptionsBuilder(context),
  );
}

libraryOptionsBuilder(BuildContext context) => Dialog(
      backgroundColor: Color.fromRGBO(10, 10, 10, 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LibraryOptions(),
      ),
    );

class LibraryOptions extends StatelessWidget {
  final TextStyle libraryOptionsFont = TextStyle(
      fontFamily: "Lato",
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, provider, _) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "More",
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text(
              "Library Collection Order",
              style: libraryOptionsFont,
            ),
            trailing: Icon(
              CupertinoIcons.square_favorites,
              color: Colors.purple,
            ),
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => LibraryOrderManagerPage(),
                  fullscreenDialog: true,
                  maintainState: true),
            ),
          ),
          ListTile(
            title: Text(
              "Migrate",
              style: libraryOptionsFont,
            ),
            trailing: Icon(
              CupertinoIcons.arrow_up_bin,
              color: Colors.purple,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LibraryMigratePage(),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Bulk Remove from Library",
              style: libraryOptionsFont,
            ),
            trailing: Icon(
              CupertinoIcons.delete,
              color: Colors.purple,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LibraryBulkDeletePage(),
              ),
            ),
          ),
          ListTile(
              title: Text(
                provider.libraryViewMode == 1
                    ? "Switch to ListView"
                    : "Switch to GridView",
                style: libraryOptionsFont,
              ),
              trailing: Icon(
                provider.libraryViewMode == 1
                    ? CupertinoIcons.list_dash
                    : CupertinoIcons.rectangle_grid_3x2,
                color: Colors.purple,
              ),
              onTap: () {
                if (provider.libraryViewMode != 1)
                  provider.setLibraryViewMode(1);
                else
                  provider.setLibraryViewMode(2);
              }),
        ],
      );
    });
  }
}
