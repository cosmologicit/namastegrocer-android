import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final int _currentIndex = 4;

  void _handleNavigation(int index) {
    NavigationHelper.navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              'Last Updated: September 29, 2025',
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
              'We may collect information about you in a variety of ways. The information we may collect via the Application includes:\n\n'
                  '•  **Personal Data:** Personally identifiable information, such as your name, shipping address, email address, and telephone number that you voluntarily give to us when you register with the Application.\n'
                  '•  **Usage Data:** Information our servers automatically collect when you access the Application, such as your IP address, your browser type, your operating system, your access times, and the pages you have viewed directly before and after accessing the Application.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. How We Use Your Information'),
            const SizedBox(height: 8),
            _buildParagraph(
              'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:\n\n'
                  '•  Create and manage your account.\n'
                  '•  Process your orders and payments.\n'
                  '•  Email you regarding your account or order.\n'
                  '•  Notify you of updates to the Application.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Data Security'),
            const SizedBox(height: 8),
            _buildParagraph(
              'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  // Helper widget for section titles
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

  // Helper widget for paragraphs
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