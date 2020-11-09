import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> favorites;
  List<String> collections;
  FavoritesManager _manager = FavoritesManager();

  init() async {
    favorites = await _manager.getAll();
    collections = await _manager.getCollections();
  }

  add(Favorite favorite) async {
    Favorite returnValue =  await _manager.save(favorite);
  }
  update(Favorite favorite) async {}
  delete(Favorite favorite) async {}


}
