import 'package:flutter/material.dart';


class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() {
    return _instance;
  }
  FavoritesManager._internal();

  final Map<int, dynamic> _favoriteProducts = {};

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
    notifyListeners();
  }
}