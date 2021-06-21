import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Services/cookie_manager.dart';
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
    cookieManagerr.clearCookies();
  }

  String clearance = "";
  final cookieManagerr = TestCookieManager();

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: false,
      userAgent: "MangaSoup/0.0.3",
      onWebResourceError: (err) => {print(err.description)},
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        webViewController.clearCache();
        final cookieManager = CookieManager();
        cookieManager.clearCookies();
        cookieManagerr.clearCookies();
      },
      javascriptChannels: <JavascriptChannel>[
        _toasterJavascriptChannel(context),
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          print('blocking navigation to $request}');
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {

        if (url.contains("__cf_chl_jschl")){
          _controller.future.then((view) async {
            String clearance = "";
            final gotCookies = await cookieManagerr.testGetCookies(widget.url);
            for (var item in gotCookies) {
              // required Cookies
              clearance += "${item.name}=${item.value}; ";
            }
            Navigator.pop(context, clearance);
          });
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
