import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/services/track/anilist/anilist_api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AniListLogin extends StatefulWidget {
  @override
  _AniListLoginState createState() => _AniListLoginState();
}

class _AniListLoginState extends State<AniListLogin> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text("AniList Login"),
      ),
      body: AniListWebView(),
    );
  }
}

class AniListWebView extends StatefulWidget {
  @override
  _AniListWebViewState createState() => _AniListWebViewState();
}

class _AniListWebViewState extends State<AniListWebView> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      userAgent: "MangaSoup/0.0.2",
      //1yEXPJu9UtGB
      javascriptMode: JavascriptMode.unrestricted,
      // debuggingEnabled: true,
      onWebResourceError: (err) => {print(err.description)},
      onWebViewCreated: (WebViewController webViewController) {
        webViewController.loadUrl(AniList.loginAddress());
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
        if (url.contains("access_token")) {
          debugPrint(url);
          String token = url.split('access_token=').last.split('&').first;
          Navigator.pop(context, token);
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
