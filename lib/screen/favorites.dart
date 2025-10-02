import 'package:flutter/material.dart';
import 'package:sample/screen/product_detail.dart';
import '../utils/cart_manager.dart';
import '../utils/favorites_manager.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onStateChanged);
    _cartManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onStateChanged);
    _cartManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favoriteItems = _favoritesManager.favorites;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: favoriteItems.isEmpty
          ? _buildEmptyFavorites()
          : _buildFavoritesGrid(favoriteItems),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No Favorites Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            "Tap the heart on any product to save it here.",
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(List<dynamic> favoriteItems) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: favoriteItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = favoriteItems[index];
        final int productId = product['id'];
        return ProductCard(
          product: product,
          isFavorite: _favoritesManager.isFavorite(productId),
          quantity: _cartManager.cart[productId]?['quantity'] ?? 0,
          onToggleFavorite: () => _favoritesManager.toggleFavorite(product),
          onIncrement: () => _cartManager.addItem(product),
          onDecrement: () => _cartManager.removeItem(productId),
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: productId)),
            );
          },
        );
      },
    );
  }
}