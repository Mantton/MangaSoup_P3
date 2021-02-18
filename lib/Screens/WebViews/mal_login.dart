import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/services/track/myanimelist/mal_api_manager.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class MALLogin extends StatefulWidget {
  @override
  _MALLoginState createState() => _MALLoginState();
}

class _MALLoginState extends State<MALLogin> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text("MyAnimeList Login"),
      ),
      body: MALWebView(
        url: MALManager.generateOAuthRoute(),
      ),
    );
  }
}

class MALWebView extends StatefulWidget {
  final String url;

  const MALWebView({Key key, this.url}) : super(key: key);

  @override
  MALWebViewState createState() => MALWebViewState();
}

class MALWebViewState extends State<MALWebView> {
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
      userAgent: "MangaSoup/0.0.2",
      //1yEXPJu9UtGB
      javascriptMode: JavascriptMode.unrestricted,
      // debuggingEnabled: true,
      onWebResourceError: (err) => {print(err.description)},
      onWebViewCreated: (WebViewController webViewController) {
        webViewController.loadUrl(widget.url);
        // _controller.complete(webViewController);
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
        if (url.contains("?code=")) {
          String verifier = widget.url.split("&code_challenge=").last;
          String code = url.split("?code=").last;
          Navigator.pop(context, [code, verifier]);
        }
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
