import 'package:flutter/material.dart';

class ShippingInfoScreen extends StatelessWidget {
  const ShippingInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Information'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: 'Delivery Timelines',
              content:
              'We offer same-day delivery for all orders placed before 2:00 PM. Orders placed after 2:00 PM will be delivered the next day. Our standard delivery slot is between 9:00 AM and 9:00 PM.',
            ),
            InfoSection(
              title: 'Shipping Charges',
              content:
              'A flat shipping fee of ₹50 is applied to all orders below ₹500. We are happy to offer FREE delivery on all orders with a total value of ₹500 or more.',
            ),
            InfoSection(
              title: 'Coverage Area',
              content:
              'We are currently serving all major areas within Delhi, Mumbai, and Bengaluru. We are expanding our services to new cities very soon. You can check serviceability in your area by entering your pincode at checkout.',
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for styling text sections
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