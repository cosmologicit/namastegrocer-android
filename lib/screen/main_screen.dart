import 'package:flutter/material.dart';
import 'package:sample/screen/account_page.dart';
import 'package:sample/screen/all_categories_page.dart';
import 'package:sample/screen/cart.dart';
import 'package:sample/screen/favorites.dart';
import 'package:sample/screen/home.dart';
import '../widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const AllCategoriesPage(),
      CartPage(onNavigateToTab: _onTap),
      const FavoritesPage(),
      AccountPage(onNavigateToTab: _onTap),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}