import 'package:flutter/material.dart';

class ReachedEndPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
            "That was the last available chapter, add to library to be updated when more chapters are released!"),
      ),
    );
  }
}
