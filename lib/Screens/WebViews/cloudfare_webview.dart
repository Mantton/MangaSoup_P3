import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class CloudFareBypass extends StatefulWidget {
  final String url;

  const CloudFareBypass({Key key, @required this.url}) : super(key: key);
  @override
  _CloudFareBypassState createState() => _CloudFareBypassState();
}

class _CloudFareBypassState extends State<CloudFareBypass> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(),
      body: WebViewExample(
        url: widget.url,
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
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: true,
      onWebResourceError: (err)=>{
        print(err.description)
      },
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
          print('blocking navigation to $request}');
          return NavigationDecision.prevent;
        }
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url){
        _controller.future.then((view) async {
          final String cookies =
              await view.evaluateJavascript('document.cookie');
          print("Retrieved Cookies");
          print(cookies);
          Navigator.pop(context, cookies);
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
