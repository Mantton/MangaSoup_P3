import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/services/mangasoup_combined_testing.dart';

class MangaSoupSignInSignUP extends StatefulWidget {
  @override
  _MangaSoupSignInSignUPState createState() => _MangaSoupSignInSignUPState();
}

class _MangaSoupSignInSignUPState extends State<MangaSoupSignInSignUP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("MangaSoup"),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Continue with one of the listed services to to access MangaSoup Topics",
                style: notInLibraryFont,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Image.asset("assets/images/mangadex.png"),
              title: Text(
                "Continue with MangaDex",
                style: notInLibraryFont,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
              onTap: () async => _continueWithMangaDexLogic(context).then(
                (value) => value ? Navigator.pop(context, true) : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _continueWithMangaDexLogic(BuildContext context) async {
    bool success = false;
    showLoadingDialog(context);
    try {
      await MSCombined().authorizeWithDex(context);
      debugPrint("Done");
      success = true;
    } catch (err) {
      if (err is MissingMangaDexSession) {
        showSnackBarMessage("You are not Logged in to MangaDex");
      } else
        showSnackBarMessage(err.toString());
    }
    Navigator.pop(context);
    return success;
  }
}
