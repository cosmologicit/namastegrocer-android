import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final bool isFavorite;
  final int quantity;
  final VoidCallback onToggleFavorite;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onCardTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.quantity,
    required this.onToggleFavorite,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // API se image URL ko handle karne ka logic
    String imageUrl = '';
    if (product['imageUrl'] != null) {
      if (product['imageUrl'] is List && product['imageUrl'].isNotEmpty) {
        imageUrl = product['imageUrl'][0];
      } else if (product['imageUrl'] is String) {
        imageUrl = product['imageUrl'];
      }
    }

    // API se price ko handle karne ka logic
    String priceString = 'N/A';
    if (product['price'] != null) {
      if (product['price'] is String && product['price'].startsWith('₹')) {
        priceString = product['price'];
      } else {
        priceString = '₹${product['price']}';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                        ),
                      )
                          : const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onToggleFavorite,
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
                  Text(priceString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
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
                  onPressed: onIncrement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.purple.shade200),
                    ),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                )
                    : Container(
                  decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                        onPressed: onDecrement,
                        padding: EdgeInsets.zero,
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                        onPressed: onIncrement,
                        padding: EdgeInsets.zero,
                      ),
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
}