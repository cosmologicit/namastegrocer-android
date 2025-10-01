import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:sample/screen/product_detail.dart';
import 'package:sample/screen/product_list.dart';
import 'dart:convert';

import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import '../utils/favorites_manager.dart';
import '../utils/cart_manager.dart';
import '../widgets/product_card.dart';
import 'all_categories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> banners = [
    "lib/image/banner1.jpg", "lib/image/banner2.jpg", "lib/image/banner3.jpg",
    "lib/image/banner4.jpg", "lib/image/banner5.jpg",
  ];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> latestProducts = [];
  List<Map<String, dynamic>> categoriesWithProducts = [];
  bool isLoadingCategories = true, isLoadingProducts = true, isLoadingCategoriesWithProducts = true;
  String categoriesErrorMessage = '', productsErrorMessage = '', categoriesWithProductsErrorMessage = '';
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FavoritesManager _favoritesManager = FavoritesManager();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchLatestProducts();
    fetchCategoriesWithProducts();
    _favoritesManager.addListener(_onStateChanged);
    _cartManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onStateChanged);
    _cartManager.removeListener(_onStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> fetchAllData() async {
    await fetchCategories();
    await fetchLatestProducts();
    await fetchCategoriesWithProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://13.127.232.90:8084/category/getAll'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') setState(() => categories = List<Map<String, dynamic>>.from(data['data']));
      }
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => isLoadingCategories = false);
  }

  Future<void> fetchLatestProducts() async {
    try {
      final response = await http.get(Uri.parse('http://13.127.232.90:8084/product/latest'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') setState(() => latestProducts = List<Map<String, dynamic>>.from(data['data']));
      }
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => isLoadingProducts = false);
  }

  Future<void> fetchCategoriesWithProducts() async {
    try {
      final response = await http.get(Uri.parse('http://13.127.232.90:8084/product/get-all-category-with-product'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') setState(() => categoriesWithProducts = List<Map<String, dynamic>>.from(data['data']));
      }
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => isLoadingCategoriesWithProducts = false);
  }

  void _navigateToProductDetail(int productId) => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: productId)));
  void _navigateToCategoryProducts(int categoryId, String categoryName) => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(categoryId: categoryId, categoryName: categoryName)));
  void _navigateToAllCategories() => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCategoriesPage()));
  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    NavigationHelper.navigateToPage(context, index);
  }

  List<dynamic> getDisplayCategories() {
    if (categories.isEmpty) return [];
    List<dynamic> displayCategories = categories.take(5).toList();
    if (categories.length > 5) displayCategories.add({"name": "View All", "isViewAll": true});
    return displayCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Namaste Grocer"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {})],
      ),
      body: RefreshIndicator(
        onRefresh: fetchAllData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Find Products... Search Store",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              if (banners.isNotEmpty) CarouselSlider(
                options: CarouselOptions(height: 180, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.9),
                items: banners.map((item) => Container(
                  margin: const EdgeInsets.all(5.0),
                  child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(item, fit: BoxFit.cover, width: double.infinity)),
                )).toList(),
              ),
              const SizedBox(height: 20),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              isLoadingCategories ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())) : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9),
                itemCount: getDisplayCategories().length,
                itemBuilder: (context, index) {
                  final category = getDisplayCategories()[index];
                  bool isViewAll = category['isViewAll'] == true;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => isViewAll ? _navigateToAllCategories() : _navigateToCategoryProducts(category['id'], category['name']),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isViewAll ? const Icon(Icons.arrow_forward, size: 32, color: Colors.purple) : Image.network(
                            category['imageUrl'] ?? '', height: 40, width: 40, fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(Icons.category, size: 32, color: Colors.purple),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(category['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Padding(padding: EdgeInsets.all(16.0), child: Text("Latest Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              isLoadingProducts ? const Center(child: CircularProgressIndicator()) : SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: latestProducts.length,
                  itemBuilder: (context, index) {
                    final product = latestProducts[index];
                    final int productId = product['id'];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ProductCard(
                        product: product,
                        isFavorite: _favoritesManager.isFavorite(productId),
                        quantity: _cartManager.cart[productId]?['quantity'] ?? 0,
                        onToggleFavorite: () => _favoritesManager.toggleFavorite(product),
                        onIncrement: () => _cartManager.addItem(product),
                        onDecrement: () => _cartManager.removeItem(productId),
                        onCardTap: () => _navigateToProductDetail(productId),
                      ),
                    );
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoriesWithProducts.length,
                itemBuilder: (context, index) {
                  final category = categoriesWithProducts[index];
                  final products = category['productResponseList'] as List<dynamic>? ?? [];
                  if (products.isEmpty) return const SizedBox();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            TextButton(onPressed: () => _navigateToCategoryProducts(category['id'], category['name']), child: const Text("View All", style: TextStyle(color: Colors.purple))),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: products.length,
                          itemBuilder: (context, productIndex) {
                            final product = products[productIndex];
                            final int productId = product['id'];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ProductCard(
                                product: product,
                                isFavorite: _favoritesManager.isFavorite(productId),
                                quantity: _cartManager.cart[productId]?['quantity'] ?? 0,
                                onToggleFavorite: () => _favoritesManager.toggleFavorite(product),
                                onIncrement: () => _cartManager.addItem(product),
                                onDecrement: () => _cartManager.removeItem(productId),
                                onCardTap: () => _navigateToProductDetail(productId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: _currentIndex, onTap: _handleNavigation),
    );
  }
}