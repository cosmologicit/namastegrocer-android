import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get In Touch",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We are here to help you. Reach out to us through any of the following channels.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.purple),
                title: const Text('Email Support'),
                subtitle: const Text('support@namastegrocer.com'),
                onTap: () {
                  // TODO: Launch email app
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_outlined, color: Colors.purple),
                title: const Text('Phone Support'),
                subtitle: const Text('+91 98765 43210'),
                onTap: () {
                  // TODO: Launch phone dialer
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city_outlined, color: Colors.purple),
                title: const Text('Corporate Address'),
                subtitle: const Text('123, Grocery Lane, Tech Park, Bengaluru, 560100'),
                onTap: () {
                  // TODO: Launch maps
                },
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Business Hours",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Monday - Saturday: 9:00 AM - 8:00 PM\nSunday: 10:00 AM - 6:00 PM",
              style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}