import 'package:flutter/material.dart';
import 'package:sample/screen/product_detail.dart';
import '../utils/cart_manager.dart';
import '../utils/favorites_manager.dart';
import '../widgets/product_card.dart';

class CategoryProductsPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> products = [];

  final FavoritesManager _favoritesManager = FavoritesManager();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    products = List<Map<String, dynamic>>.from(widget.category['products']);
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
          ? const Center(child: Text("No products available in this category.", style: TextStyle(fontSize: 18, color: Colors.grey)))
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
            quantity: _cartManager.cart[productId]?['quantity'] ?? 0,
            onToggleFavorite: () => _favoritesManager.toggleFavorite(product),
            onIncrement: () => _cartManager.addItem(product),
            onDecrement: () => _cartManager.removeItem(productId),
            onCardTap: () => _navigateToProductDetail(productId),
          );
        },
      ),
    );
  }
}