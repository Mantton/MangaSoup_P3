import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Globals.dart';

class MangadexLoginPage extends StatefulWidget {
  @override
  _MangadexLoginPageState createState() => _MangadexLoginPageState();
}

class _MangadexLoginPageState extends State<MangadexLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  TextStyle subheaderFont =
      TextStyle(fontFamily: "Raleway", color: Colors.white, fontSize: 20.0.sp);

  // text-field state
  bool loading = false;
  FocusNode spectacle;
  String _username;
  String _password;
  Color primary = Colors.white;
  DexHub _dex = DexHub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0,
        title: Text("MangaDex Login"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            // UserName
            userFormField(),

            SizedBox(
              height: 20,
            ),
            // Password
            passwordFormField(),
            SizedBox(
              height: 15,
            ),

            Center(
              child: MaterialButton(
                disabledColor: Colors.grey[900],
                height: 50,
                minWidth: MediaQuery.of(context).size.width - 200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: Colors.purple[900],
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: (_username == "" ||
                        _username == null ||
                        _password == "" ||
                        _password == null)
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        debugPrint("Starting");
                        showLoadingDialog(context);
                        bool success = await _dex.login(_username, _password);
                        Navigator.pop(context);
                        if (success){
                          Navigator.pop(context, "MangaDex Login Successful!");
                          sourcesStream.add(""); // Rebuild Pages with new cookies
                        }

                        else
                          _showErrorDialog();
                      },
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(
            width: 3,
          ),
          Text(
            error,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget userFormField() {
    return TextField(
        decoration: InputDecoration(
          hintText: "UserName",
          contentPadding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[800]),
            gapPadding: 5,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[600]),
            gapPadding: 5,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red),
            gapPadding: 5,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.redAccent),
            gapPadding: 5,
          ),
          suffixIcon: Icon(
            Icons.person,
            color: Colors.purple,
          ),
        ),
        cursorColor: Colors.grey,
        maxLines: 1,
        style: TextStyle(
          height: 1.7,
          color: Colors.grey,
          fontSize: 18,
        ),
        onChanged: (val) {
          setState(() {
            _username = val;
          });
        });
  }

  Widget passwordFormField() {
    return TextField(
        decoration: InputDecoration(
          hintText: "Password",
          contentPadding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[800]),
            gapPadding: 5,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[600]),
            gapPadding: 5,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red),
            gapPadding: 5,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.redAccent),
            gapPadding: 5,
          ),
          suffixIcon: Icon(
            Icons.vpn_key,
            color: Colors.purple,
          ),
        ),
        cursorColor: Colors.grey,
        maxLines: 1,
        obscureText: true,
        style: TextStyle(
          height: 1.7,
          color: Colors.grey,
          fontSize: 18,
        ),
        onChanged: (val) {
          setState(() {
            _password = val;
          });
        });
  }

  _showErrorDialog() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Login Failed'),
        content: Text('Invalid Credentials'),
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: ()=>Navigator.pop(context),
            child: Text("OK"),
          ),

        ],
      ),
    );
  }
}
//
//(newUser.email == null ||
//newUser.password == null)
//? null
//: ()
