import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/track/mal/mal_screen.dart';

class TrackingServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("built");
    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: Color.fromRGBO(6, 6, 6, 1.0),
              title: Text("MyAnimeList"),
              leading: Image.asset("assets/images/mal.png"),
              trailing: Icon(
                CupertinoIcons.forward,
                color: Colors.white,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MALHome(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
