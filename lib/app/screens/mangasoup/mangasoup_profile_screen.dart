import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/mangasoup/mangasoup_auth_screen.dart';
import 'package:mangasoup_prototype_3/app/services/mangasoup_combined_testing.dart';
import 'package:provider/provider.dart';

class MangaSoupUserHome extends StatefulWidget {
  @override
  _MangaSoupUserHomeState createState() => _MangaSoupUserHomeState();
}

class _MangaSoupUserHomeState extends State<MangaSoupUserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MangaSoup"),
        centerTitle: true,
      ),
      body: Consumer<PreferenceProvider>(builder: (context, provider, _) {
        return Container(
          child: ListTile(
            title: Text(provider.msUser != null ? "Log Out" : "Log In"),
            onTap: () async {
              if (provider.msUser == null)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MangaSoupSignInSignUP(),
                  ),
                );
              else {
                try {
                  showLoadingDialog(context);
                  await MSCombined().logOut(context);
                  Navigator.pop(context);
                } catch (err) {
                  Navigator.pop(context);
                  showSnackBarMessage(err.toString(), error: true);
                }
              }
            },
          ),
        );
      }),
    );
  }
}
