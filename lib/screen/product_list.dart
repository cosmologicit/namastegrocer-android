import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/screen/product_detail.dart';
import 'dart:convert';

import '../utils/favorites_manager.dart';
import '../utils/cart_manager.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';
  int _currentIndex = 1;
  final FavoritesManager _favoritesManager = FavoritesManager();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
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

  Future<void> _fetchProductsByCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse(
          'http://13.127.232.90:8084/product/get-product-by-category-id/${widget.categoryId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() => products = data['data'] ?? []);
        } else {
          setState(() => errorMessage = data['message'] ?? 'Failed to load products');
        }
      } else {
        setState(() => errorMessage = 'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error fetching products: $e');
    }
    setState(() => isLoading = false);
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
        title: Text(widget.categoryName),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : products.isEmpty
          ? const Center(child: Text("No products found in this category."))
          : RefreshIndicator(
        onRefresh: _fetchProductsByCategory,
        child: GridView.builder(
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
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}