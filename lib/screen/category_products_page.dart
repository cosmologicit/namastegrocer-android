import 'package:flutter/material.dart';
import 'package:sample/screen/product_detail.dart';
import '../utils/favorites_manager.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import '../widgets/product_card.dart';

class CategoryProductsPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> products = [];
  int _currentIndex = 1;

  final FavoritesManager _favoritesManager = FavoritesManager();
  final Map<int, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    products = List<Map<String, dynamic>>.from(widget.category['products']);
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

  void _incrementQuantity(int productId) => setState(() => _cartQuantities[productId] = (_cartQuantities[productId] ?? 0) + 1);
  void _decrementQuantity(int productId) {
    setState(() {
      if ((_cartQuantities[productId] ?? 0) > 1) {
        _cartQuantities[productId] = _cartQuantities[productId]! - 1;
      } else {
        _cartQuantities.remove(productId);
      }
    });
  }

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    NavigationHelper.navigateToPage(context, index);
  }

  void _navigateToProductDetail(int productId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: productId)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category['name']),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products available", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final int productId = product['id'];
          return ProductCard(
            product: product,
            isFavorite: _favoritesManager.isFavorite(productId),
            quantity: _cartQuantities[productId] ?? 0,
            onToggleFavorite: () => _favoritesManager.toggleFavorite(product),
            onIncrement: () => _incrementQuantity(productId),
            onDecrement: () => _decrementQuantity(productId),
            onCardTap: () => _navigateToProductDetail(productId),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}