import 'package:flutter/material.dart';
import '../screen/account_page.dart';
import '../screen/all_categories_page.dart';
import '../screen/cart.dart';
import '../screen/favorites.dart';
import '../screen/home.dart';

class NavigationHelper {
  static void navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Shop/Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
        );
        break;
      case 1: // Category
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllCategoriesPage()),
        );
        break;
      case 2: // Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
      case 3: // Favourite
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPage()),
        );
        break;
      case 4: // Account
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
        break;
    }
  }
}