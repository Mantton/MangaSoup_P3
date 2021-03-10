import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/language_server.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:provider/provider.dart';

class LanguageServerPage extends StatefulWidget {
  @override
  _LanguageServerPageState createState() => _LanguageServerPageState();
}

class _LanguageServerPageState extends State<LanguageServerPage> {
  Future<List<LanguageServer>> servers;

  @override
  void initState() {
    servers = ApiManager().getLanguageServers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Language Servers"),
      ),
      body: FutureBuilder(
        future: servers,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
              child: Center(
                child: LoadingIndicator(),
              ),
            );
          else if (snapshot.hasError)
            return Container(
              child: Center(
                child: Text(
                  "Failed to load language servers\n${snapshot.error}",
                  style: notInLibraryFont,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          else if (!snapshot.hasData)
            return Container(
              child: Center(
                child: Text(
                  "Critical Error\nYou should not be seeing this",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          else
            return ServerList(
              servers: snapshot.data,
            );
        },
      ),
    );
  }
}

class ServerList extends StatelessWidget {
  final List<LanguageServer> servers;

  const ServerList({Key key, this.servers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String current = Provider.of<PreferenceProvider>(context).languageServer;
    if (current == "live") current = "en";

    return ListView.separated(
        itemBuilder: (_, index) => ListTile(
              tileColor: Color.fromRGBO(10, 10, 10, 1.0),
              title: Text(
                servers[index].name,
                style: notInLibraryFont,
              ),
              trailing: (current == servers[index].selector)
                  ? Icon(Icons.check)
                  : null,
              onTap: () async {
                showLoadingDialog(context);
                await Provider.of<PreferenceProvider>(context, listen: false)
                    .setLanguageServer(servers[index].selector);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
        separatorBuilder: (_, index) => SizedBox(
              height: 5,
            ),
        itemCount: servers.length);
  }
}
