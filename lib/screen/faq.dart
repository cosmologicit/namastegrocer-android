import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: const <Widget>[
          FaqTile(
            question: 'How do I place an order?',
            answer:
            'You can place an order by browsing our categories, adding products to your cart, and proceeding to checkout. Just follow the on-screen instructions.',
          ),
          FaqTile(
            question: 'What are the delivery charges?',
            answer:
            'Delivery charges are ₹50 for orders below ₹500. We offer free delivery for all orders of ₹500 or more.',
          ),
          FaqTile(
            question: 'How can I track my order?',
            answer:
            'You can track your order status in the "My Orders" section of the app. We will also send you notifications at every step.',
          ),
          FaqTile(
            question: 'What is your return policy?',
            answer:
            'We accept returns for non-perishable items within 7 days of delivery. For fresh fruits and vegetables, returns are accepted within 24 hours if the product is not satisfactory.',
          ),
          FaqTile(
            question: 'Which payment methods are accepted?',
            answer:
            'We accept all major payment methods including UPI, Credit/Debit Cards, Net Banking, and Cash on Delivery (COD).',
          ),
        ],
      ),
    );
  }
}

// Helper widget for consistent styling
class FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const FaqTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            answer,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}