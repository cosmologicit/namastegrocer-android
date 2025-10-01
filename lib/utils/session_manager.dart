import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cart_manager.dart';
import 'favorites_manager.dart';

class SessionManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveSession(Map<String, dynamic> responseData) async {
    String userDataString = json.encode(responseData);
    await _prefs?.setString('userData', userDataString);
  }

  static String? getToken() {
    String? userDataString = _prefs?.getString('userData');
    if (userDataString == null) return null;
    Map<String, dynamic> userData = json.decode(userDataString);
    return userData['token'];
  }

  static Map<String, dynamic>? getUserData() {
    String? userDataString = _prefs?.getString('userData');
    if (userDataString == null) return null;
    return json.decode(userDataString);
  }

  static bool isLoggedIn() {
    return _prefs?.getString('userData') != null;
  }

  static Future<void> logout() async {
    await _prefs?.clear();
    CartManager().clearLocalData();
    FavoritesManager().clearLocalData();
  }
}