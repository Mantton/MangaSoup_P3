import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> favorites;
  Map sortedFavorites = Map();
  List<String> collections = List();
  List<String> updateEnabledCollections = List();
  FavoritesManager _manager = FavoritesManager();

  init() async {
    favorites = await _manager.getAll(); // Get All
    sortedFavorites = groupBy(
      favorites,
      (Favorite obj) => obj.collection,
    ); // Sort Favorites
    collections = sortedFavorites.keys.toList(); // Get all collections

    // Update Enabled Collections
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    updateEnabledCollections = _prefs.getStringList("uec") ?? [];

    notifyListeners();
  }

  add(Favorite favorite) async {
    Favorite returnValue = await _manager.save(favorite);
  }

  update(Favorite favorite) async {}

  delete(Favorite favorite) async {}
}
