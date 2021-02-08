import 'package:flutter/material.dart';

class ReachedEndPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text(
          "That was the last available chapter.\n"
              " Add this comic to your library to be updated when more chapters are released!",
        ),
        // add button
        // recommendations
      ),
    );
  }
}
