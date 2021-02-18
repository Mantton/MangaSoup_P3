import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';

malSearchDialog(
    {@required BuildContext context, String initialQuery, int trackId}) {
  showGeneralDialog(
    barrierLabel: "MAL Query Search",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => MALQuery(),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

class MALQuery extends StatefulWidget {
  final String initialQuery;

  const MALQuery({Key key, this.initialQuery}) : super(key: key);

  @override
  _MALQueryState createState() => _MALQueryState();
}

class _MALQueryState extends State<MALQuery> {
  List results = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: mangasoupInputDecoration("Title"),
            onChanged: (q) {},
          ),
          ListView.builder(itemBuilder: null)
        ],
      ),
    );
  }
}
