import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/screen/product_detail.dart';
import 'dart:convert';

// ADDED: Favorites Manager ko import karein
import '../utils/favorites_manager.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';

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
  final Map<int, int> _cartQuantities = {};

  // ADDED: Favorites Manager ka instance banayein
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
    // ADDED: Listener add karein taaki UI update ho jab favorites change ho
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    // ADDED: Memory leak se bachne ke liye listener ko remove karein
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  // ADDED: Yeh function call hoga jab bhi favorites list update hogi
  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {
        // Just rebuild the widget to update the favorite icons
      });
    }
  }

  Future<void> _fetchProductsByCategory() async {
    // ... baaki ka code same rahega ...
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
          setState(() {
            products = data['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load products';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
          'Failed to load products. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products: $e';
        isLoading = false;
      });
    }
  }

  // ... _handleNavigation, _navigateToProductDetail, _incrementQuantity, _decrementQuantity functions same rahenge ...
  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
    NavigationHelper.navigateToPage(context, index);
  }

  void _navigateToProductDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  void _incrementQuantity(int productId) {
    setState(() {
      _cartQuantities[productId] = (_cartQuantities[productId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int productId) {
    setState(() {
      if (_cartQuantities.containsKey(productId)) {
        if (_cartQuantities[productId]! > 1) {
          _cartQuantities[productId] = _cartQuantities[productId]! - 1;
        } else {
          _cartQuantities.remove(productId);
        }
      }
    });
  }


  Widget _buildProductCard(dynamic product) {
    final int productId = product['id'];
    final int quantity = _cartQuantities[productId] ?? 0;
    // ADDED: Check if the product is favorite
    final bool isFavorite = _favoritesManager.isFavorite(productId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _navigateToProductDetail(productId),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHANGED: Image ko Stack mein daala taaki icon ko upar place kar sakein
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: (product['imageUrl'] != null &&
                          product['imageUrl'] is List &&
                          product['imageUrl'].isNotEmpty)
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['imageUrl'][0],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey);
                          },
                        ),
                      )
                          : const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                    ),
                    // ADDED: Favorite icon button
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _favoritesManager.toggleFavorite(product);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['name'] ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('₹${product['price']?.toString() ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(width: 4),
                  Text(product['unit'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: quantity == 0
                    ? ElevatedButton(
                  onPressed: () => _incrementQuantity(productId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.purple.shade200)
                    ),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                )
                    : Container(
                  decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: Colors.white, size: 16), onPressed: () => _decrementQuantity(productId), padding: EdgeInsets.zero),
                      Text(quantity.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 16), onPressed: () => _incrementQuantity(productId), padding: EdgeInsets.zero),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... baaki ka build method same rahega ...
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProductsByCategory,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      )
          : products.isEmpty
          ? const Center(
        child: Text(
          "No products found in this category.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
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
            return _buildProductCard(products[index]);
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