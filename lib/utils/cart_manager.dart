import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  static SharedPreferences? _prefs;
  Map<int, Map<String, dynamic>> _cartItems = {};

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance._loadCart();
  }

  void _loadCart() {
    String? cartString = _prefs?.getString('cartItems');
    if (cartString != null) {
      Map<String, dynamic> decodedMap = json.decode(cartString);
      _cartItems = decodedMap.map((key, value) => MapEntry(int.parse(key), value as Map<String, dynamic>));
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    String cartString = json.encode(_cartItems.map((key, value) => MapEntry(key.toString(), value)));
    await _prefs?.setString('cartItems', cartString);
  }

  void clearLocalData() {
    _cartItems.clear();
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> get cart => _cartItems;
  List<Map<String, dynamic>> get items => _cartItems.values.toList();

  int get totalItems {
    if (_cartItems.isEmpty) return 0;
    return _cartItems.values
        .map<int>((item) => item['quantity'] as int)
        .fold(0, (a, b) => a + b);
  }

  double get totalPrice {
    if (_cartItems.isEmpty) return 0.0;
    return _cartItems.values
        .map<double>((item) =>
    (item['product']['price'] as num).toDouble() * (item['quantity'] as int))
        .fold(0.0, (a, b) => a + b);
  }

  void addItem(dynamic product, [int quantity = 1]) {
    final int productId = product['id'];
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId]!['quantity'] += quantity;
    } else {
      _cartItems[productId] = {'product': product, 'quantity': quantity};
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(int productId) {
    if (!_cartItems.containsKey(productId)) return;
    if (_cartItems[productId]!['quantity'] > 1) {
      _cartItems[productId]!['quantity']--;
    } else {
      _cartItems.remove(productId);
    }
    _saveCart();
    notifyListeners();
  }

  void clearItem(int productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.remove(productId);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();
    notifyListeners();
  }
}