import 'package:flutter/material.dart';
import '../utils/favorites_manager.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _currentIndex = 3;
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    NavigationHelper.navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteItems = _favoritesManager.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: favoriteItems.isEmpty
          ? _buildEmptyFavorites()
          : _buildFavoritesList(favoriteItems),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("You have no favorites yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text("Tap the heart on any product to save it here.", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<dynamic> favoriteItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        final product = favoriteItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    (product['imageUrl'] != null && product['imageUrl'].isNotEmpty) ? product['imageUrl'][0] : '',
                    width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? 'No Name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${product['price'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _favoritesManager.toggleFavorite(product),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}