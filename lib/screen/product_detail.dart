import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/cart_manager.dart';
import '../utils/favorites_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  String errorMessage = '';
  int _quantity = 1;
  final CartManager _cartManager = CartManager();
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _favoritesManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://13.127.232.90:8084/product/${widget.productId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() => product = data['data']);
        } else {
          setState(() => errorMessage = data['message'] ?? 'Failed to load details');
        }
      } else {
        setState(() => errorMessage = 'Failed to load. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    }
    setState(() => isLoading = false);
  }

  void _increaseQuantity() => setState(() => _quantity++);

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _addToCart() {
    if (product != null) {
      _cartManager.addItem(product!, _quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product!['name']} ($_quantity) added to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = product != null ? _favoritesManager.isFavorite(product!['id']) : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (product != null)
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.white),
              onPressed: () => _favoritesManager.toggleFavorite(product!),
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : product == null
          ? const Center(child: Text("Product not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Padding for bottom sheet
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: (product!['imageUrl'] != null && product!['imageUrl'].isNotEmpty)
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(product!['imageUrl'][0], fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                  ),
                )
                    : const Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Product Name and Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(product!['name'] ?? 'No Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Text('₹${product!['price'] ?? 'N/A'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Text(product!['unit'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // Quantity Selector
            Row(
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: _decreaseQuantity),
                      Text(_quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add), onPressed: _increaseQuantity),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Description
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              product!['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 20),

            // NEWLY ADDED: Card to show all product details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow('Key Features', product!['keyFeatures']),
                    _buildDetailRow('Shelf Life', product!['shelfLife']),
                    _buildDetailRow('Seller', product!['seller']),
                    _buildDetailRow('Country of Origin', product!['countryOfOrigin']),
                    _buildDetailRow('Category', product!['category']),
                    _buildDetailRow('Flavour', product!['flavour']),
                    _buildDetailRow('Return Policy', product!['returnPolicy']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: product == null ? null : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total Price', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    '₹${(product!['price'] ?? 0) * _quantity}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget to build detail rows cleanly
  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}