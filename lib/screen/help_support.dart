import 'package:flutter/material.dart';

// ADD these imports for the new screens
import 'package:sample/screen/faq.dart';
import 'package:sample/screen/contact_us.dart';
import 'package:sample/screen/shipping_info.dart';
import 'package:sample/screen/returns_refunds.dart';
import 'package:sample/screen/about_us.dart';

import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final int _currentIndex = 4;

  void _handleNavigation(int index) {
    NavigationHelper.navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          _buildSupportOption(
            icon: Icons.quiz_outlined,
            title: 'FAQ',
            subtitle: 'Find answers to frequently asked questions',
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.contact_mail_outlined,
            title: 'Contact Us',
            subtitle: 'Get in touch with our support team',
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.local_shipping_outlined,
            title: 'Shipping Information',
            subtitle: 'Details about our shipping policies',
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingInfoScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.assignment_return_outlined,
            title: 'Returns & Refunds',
            subtitle: 'Learn about our return policy',
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReturnsRefundsScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.info_outline,
            title: 'About Us',
            subtitle: 'Learn more about our company',
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}