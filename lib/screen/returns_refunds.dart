import 'package:flutter/material.dart';

class ReturnsRefundsScreen extends StatelessWidget {
  const ReturnsRefundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns & Refunds'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: 'Return Policy',
              content:
              'Our return policy is designed to be simple. For perishable items like fruits, vegetables, and dairy, you can initiate a return within 24 hours of delivery. For all other packaged items, the return window is 7 days from the date of delivery.',
            ),
            InfoSection(
              title: 'Refund Process',
              content:
              'Once your return is received and inspected, we will initiate the refund process. The refund will be credited to your original payment method within 5-7 business days. For COD orders, the amount will be credited to your bank account provided by you.',
            ),
            InfoSection(
              title: 'Non-Returnable Items',
              content:
              'Certain items are not eligible for returns, including items on final sale and products that have been used or opened. Please check the product description for more details before purchasing.',
            ),
          ],
        ),
      ),
    );
  }
}


// Re-using the helper widget from shipping screen for consistency
class InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const InfoSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}