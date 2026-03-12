import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movie.dart';
import 'tvseries.dart';
import 'db_helper.dart';

class FavoritesProvider with ChangeNotifier {
  List<dynamic> _favorites = [];
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<dynamic> get favoritesList => _favorites;

  // constructeur :: charge les favoris au demarrage
  FavoritesProvider() {
    _loadFavorites();
  }

  // charge les favoris depuis la base de données
  // et notifie les widgets écouteurs des changements
  Future<void> _loadFavorites() async {
    _favorites = await _db.getFavorites();
    notifyListeners();
  }

  // verifie si un média est dans les favoris
  Future<bool> isFavorite(int id) async {
    return await _db.isFavorite(id);
  }

  //accepte uniquement des objets Movie ou TvSeries
  //notifie les widgets ecouteurs apres modification
  //le x cest soit un movie soit une serie
  Future<void> toggleFavorite(dynamic x) async {
    if (x is! Movie && x is! TvSeries) {
      //si x nest pas un movie et nest pas une serie
      throw ArgumentError('soit Movie ou TvSeries'); //on lance une erreur
    }

    final isFav = await _db.isFavorite(x.id);
    if (isFav) {
      await _db.removeFavorite(x.id);
      _favorites.removeWhere((m) => m.id == x.id);
    } else {
      await _db.addFavorite(x);
      _favorites.add(x);
    }
    notifyListeners();
  }

  // met a jour la note et la critique personnelle
  Future<void> rateMedia(int mediaId, double rating, String? review) async {
    await _db.updateUserRating(mediaId, rating, review);
    notifyListeners();
  }
}
