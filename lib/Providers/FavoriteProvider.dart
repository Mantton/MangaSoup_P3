import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> favorites = List();
  Map sortedFavorites = Map();
  List collections = List();
  List<String> updateEnabledCollections = List();
  FavoritesManager _manager = FavoritesManager();

  /// Management
  init() async {
    favorites = await _manager.getAll(); // Get All
    sortFavorites();
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    updateEnabledCollections = _prefs.getStringList("uec") ?? [];
    notifyListeners();
  }

  sortFavorites() {
    sortedFavorites = groupBy(
      favorites,
      (Favorite obj) => obj.collection,
    ); // Sort Favorites
    collections = sortedFavorites.keys.toList(); // Get all collections
  }

  /// Favorites
  Future<Favorite> add(Favorite favorite) async {
    Favorite fav = await _manager.save(favorite);
    favorites.add(fav);
    sortFavorites();
    notifyListeners();
    return fav;
  }

  update(Favorite favorite) async {
    await _manager.updateByID(favorite);
    int indexToUpdate = favorites.indexWhere((fav) => fav.id == favorite.id);
    favorites[indexToUpdate] = favorite;
    sortFavorites();
    notifyListeners();
    print("updated!");
  }

  delete(Favorite favorite) async {
    await _manager.deleteByID(favorite.id);
    favorites.remove(favorite);
    sortFavorites();
    notifyListeners();
    print("removed!");
  }

  returnFavorite(String link) {
    Favorite fav = favorites.firstWhere(
        (element) => element.highlight.link == link,
        orElse: () => null);
    return fav;
  }

  isFavorite(String link) {
    return favorites.map((e) => e.highlight.link).toList().contains(link);
  }

  /// Collections
  moveCollection(
      {List<Favorite> toChange,
      String oldCollectionName,
      String newCollectionName,
      bool rename,
      int collectionLength}) async {
    bool inUEC = updateEnabledCollections.contains(oldCollectionName);
    // Change Collection Name
    toChange.forEach((element) {
      element.collection = newCollectionName;
    });

    // Update in Database
    await _manager.updateBulk(toChange);

    // Update in provider object
    for (Favorite favorite in toChange) {
      int indexToUpdate = favorites.indexWhere((fav) => fav.id == favorite.id);
      favorites[indexToUpdate] = favorite;
    }

    // Renaming Logic
    if (rename) {
      // If rename is true
      if (inUEC) {
        updateEnabledCollections.remove(oldCollectionName);
        updateEnabledCollections.add(newCollectionName);
      }
    }
    // Empty collection logic
    if (inUEC && toChange.length == collectionLength)
      updateEnabledCollections.remove(oldCollectionName);

    sortFavorites(); // Sort
    notifyListeners(); // Notify Listeners
  }

  toggleUpdateEnabled(String collectionName) async {
    // Add/Remove logic
    if (updateEnabledCollections.contains(collectionName))
      updateEnabledCollections.remove(collectionName);
    else
      updateEnabledCollections.add(collectionName);

    // Shared Preferences
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList("uec", updateEnabledCollections);

    notifyListeners(); // notify
  }
}
