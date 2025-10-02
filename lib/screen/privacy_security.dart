import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for Namaste Grocer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: October 2, 2025',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Introduction'),
            const SizedBox(height: 8),
            _buildParagraph(
              'Welcome to Namaste Grocer. We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Information We Collect'),
            const SizedBox(height: 8),
            _buildParagraph(
              'We may collect information about you in a variety of ways. The information we may collect via the Application includes personal data like your name, shipping address, email, and phone number that you voluntarily give to us.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. How We Use Your Information'),
            const SizedBox(height: 8),
            _buildParagraph(
              'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. We use your information to create and manage your account, process orders, and email you about your account or order.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Data Security'),
            const SizedBox(height: 8),
            _buildParagraph(
              'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure your personal information, please be aware that no security measures are perfect or impenetrable.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }
}