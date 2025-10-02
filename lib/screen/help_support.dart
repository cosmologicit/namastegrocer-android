import 'package:flutter/material.dart';
import 'package:sample/screen/faq.dart';
import 'package:sample/screen/contact_us.dart';
import 'package:sample/screen/shipping_info.dart';
import 'package:sample/screen/returns_refunds.dart';
import 'package:sample/screen/about_us.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          _buildSupportOption(
            icon: Icons.quiz_outlined,
            title: 'FAQ',
            subtitle: 'Find answers to frequently asked questions',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.contact_mail_outlined,
            title: 'Contact Us',
            subtitle: 'Get in touch with our support team',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.local_shipping_outlined,
            title: 'Shipping Information',
            subtitle: 'Details about our shipping policies',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingInfoScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.assignment_return_outlined,
            title: 'Returns & Refunds',
            subtitle: 'Learn about our return policy',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReturnsRefundsScreen()));
            },
          ),
          _buildSupportOption(
            icon: Icons.info_outline,
            title: 'About Us',
            subtitle: 'Learn more about our company',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
            },
          ),
        ],
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