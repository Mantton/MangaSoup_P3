import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: Text("MangaSoup Discord Server"),
              onTap: () async => await _launchUniversalLinkIos(
                  "https://discord.gg/TsGw3zpKdp"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text("Support MangaSoup on Patreon"),
              onTap: () async => await _launchUniversalLinkIos(
                  "https://patreon.com/mangasoup"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text("MangaSoup SubReddit"),
              onTap: () async => await _launchUniversalLinkIos(
                  "https://reddit.com/r/mangasoup"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ),
            // Add MangaSoup Site
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUniversalLinkIos(String url) async {
  if (await canLaunch(url)) {
    final bool nativeAppLaunchSucceeded = await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
    if (!nativeAppLaunchSucceeded) {
      await launch(
        url,
        forceSafariVC: true,
      );
    }
  }
}
