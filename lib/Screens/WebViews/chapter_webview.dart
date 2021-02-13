import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class ChapterWebView extends StatefulWidget {
  final String url;
  final String title;

  const ChapterWebView({Key key, @required this.url, this.title}) : super(key: key);
  @override
  _ChapterWebViewState createState() => _ChapterWebViewState();
}

class _ChapterWebViewState extends State<ChapterWebView> {
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
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: true,
      onWebResourceError: (err)=>{
        print(err.description)
      },
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);

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
      onPageStarted: (String url) {
      },
      onPageFinished: (String url){
        _controller.future.then((view) async {

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
