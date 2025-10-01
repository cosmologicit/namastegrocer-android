import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Using a colored container as a placeholder for an image banner
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.purple.shade100,
              child: const Icon(
                Icons.storefront,
                size: 80,
                color: Colors.purple,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoSection(
                    title: 'Our Mission',
                    content:
                    'Our mission at Namaste Grocer is to deliver the freshest groceries and daily essentials right to your doorstep, with a commitment to quality, affordability, and convenience. We aim to make your grocery shopping experience seamless and enjoyable.',
                  ),
                  InfoSection(
                    title: 'Our Story',
                    content:
                    'Founded in 2024, Namaste Grocer started as a small local store with a big dream: to simplify the lives of busy families. Today, we are a fast-growing online platform serving thousands of happy customers across the country. Our focus remains on sourcing the best products and providing exceptional customer service.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Re-using the helper widget for consistency
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