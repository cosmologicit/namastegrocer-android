import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  static SharedPreferences? _prefs;
  Map<int, dynamic> _favoriteProducts = {};

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance._loadFavorites();
  }

  void _loadFavorites() {
    String? favoritesString = _prefs?.getString('favoriteProducts');
    if (favoritesString != null) {
      Map<String, dynamic> decodedMap = json.decode(favoritesString);
      _favoriteProducts = decodedMap.map((key, value) => MapEntry(int.parse(key), value));
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    String favoritesString = json.encode(_favoriteProducts.map((key, value) => MapEntry(key.toString(), value)));
    await _prefs?.setString('favoriteProducts', favoritesString);
  }

  void clearLocalData() {
    _favoriteProducts.clear();
    notifyListeners();
  }

  List<dynamic> get favorites => _favoriteProducts.values.toList();

  bool isFavorite(int productId) {
    return _favoriteProducts.containsKey(productId);
  }

  void toggleFavorite(dynamic product) {
    final int productId = product['id'];
    if (isFavorite(productId)) {
      _favoriteProducts.remove(productId);
    } else {
      _favoriteProducts[productId] = product;
    }
    _saveFavorites();
    notifyListeners();
  }
}