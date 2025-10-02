import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/screen/product_list.dart';
import 'dart:convert';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://13.127.232.90:8084/category/getAll'));

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load categories';
            isLoading = false;
          });
        }
      } else {
        if(mounted) setState(() {
          errorMessage = 'Failed to load categories';
          isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() {
        errorMessage = 'Error fetching categories: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Categories"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Image
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              "assets/images/banner4.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.purple.withOpacity(0.1),
              ),
            ),
          ),
          // Actual content (Categories Grid)
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(
                          categoryId: category['id'],
                          categoryName: category['name'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (category['imageUrl'] != null && category['imageUrl'].toString().isNotEmpty)
                          ? Image.network(
                        category['imageUrl'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 30, color: Colors.grey),
                      )
                          : const Icon(Icons.category, size: 30, color: Colors.grey),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          category['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}