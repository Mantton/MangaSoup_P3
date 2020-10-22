import 'dart:async';

StreamController<String> sourcesStream = StreamController.broadcast();
StreamController<String> favoritesStream = StreamController.broadcast();
StreamController<String> historyStream = StreamController.broadcast();

