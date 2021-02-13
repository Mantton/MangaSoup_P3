import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class MangaDexLogin extends StatefulWidget {
  @override
  _MangaDexLoginState createState() => _MangaDexLoginState();
}

class _MangaDexLoginState extends State<MangaDexLogin> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text("MangaDex Login"),
      ),
      body: WebViewExample(
        url: "https://mangadex.org/login",
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  final String url;

  const WebViewExample({Key key, this.url}) : super(key: key);
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return WebView(
      initialUrl: widget.url,
      userAgent: "MangaSoup/0.0.2",
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: true,
      onWebResourceError: (err) => {print(err.description)},
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        webViewController.clearCache();
        final cookieManager = CookieManager();
        cookieManager.clearCookies();
      },
      javascriptChannels: <JavascriptChannel>[
        _toasterJavascriptChannel(context),
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {

        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {

        _controller.future.then((view) async {

          final String cookies =
              await view.evaluateJavascript('document.cookie');
          if (cookies.contains("mangadex_session")) {
            /// Create Map
            List<String> listedCookies = cookies.split("; ");
            Map encodedCookies = Map();
            for (String c in listedCookies) {
              List d = c.split("=");
              MapEntry entry = MapEntry(d[0], d[1]);
              encodedCookies.putIfAbsent(entry.key, () => entry.value);
            }
            String session = encodedCookies['mangadex_session'];
            String rememberMe = encodedCookies['mangadex_rememberme_token'];
            Map cookie = {
              "mangadex_session": session,
            };
            if (rememberMe!=null)
              cookie.addAll({"mangadex_rememberme_token":rememberMe});
            print(cookie.toString());
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            _prefs.setString(
                  "mangadex_cookies",
                  jsonEncode(cookie));

            Navigator.pop(context);
            showSnackBarMessage("Logged In Successfully");
          }
        });
      },
      gestureNavigationEnabled: true,
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
