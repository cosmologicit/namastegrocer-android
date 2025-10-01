class SessionManager {
  static Map<String, dynamic> _userData = {};
  static String _token = '';

  static void saveUserData(Map<String, dynamic> userData) {
    _userData = userData;
    _token = userData['token'] ?? '';
    print('User data saved: ${_userData['name']}');
  }

  static Map<String, dynamic> getUserData() {
    return _userData;
  }

  static bool isLoggedIn() {
    return _token.isNotEmpty;
  }

  static void logout() {
    _userData = {};
    _token = '';
    print('User logged out');
  }

  static String getToken() {
    return _token;
  }
}