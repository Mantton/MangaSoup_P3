import 'dart:async';

StreamController<String> sourcesStream = StreamController.broadcast();
StreamController<String> favoritesStream = StreamController.broadcast();
StreamController<String> historyStream = StreamController.broadcast();

Map<String, String> imageHeaders(String link) {
  if (link.contains("mangahasu"))
    return {"Referer": "http://mangahasu.se"};
  else if (link.contains("mangakakalot"))
    return {"Referer": "https://manganelo.com/"};
  else
    return null;
}
