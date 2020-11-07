import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoadingIndicator extends StatefulWidget {
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return PlatformCircularProgressIndicator(
      cupertino: (_, __) => CupertinoProgressIndicatorData(
        radius: 14,
      ),
      material: (_, __) => MaterialProgressIndicatorData(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
    );
  }
}

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (_) => CupertinoAlertDialog(
      content:
          Container(height: 50, width: 50, child: CupertinoActivityIndicator()),
    ),
  );
}
