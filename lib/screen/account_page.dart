import 'package:flutter/material.dart';
import 'package:sample/screen/manage_addresses.dart';
import 'package:sample/screen/my_orders.dart';
import 'package:sample/screen/privacy_security.dart';
import 'package:sample/screen/help_support.dart';
import '../utils/session_manager.dart';
import 'login.dart';
import 'signup.dart';

class AccountPage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const AccountPage({super.key, required this.onNavigateToTab});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoggedIn = false;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    bool loggedIn = SessionManager.isLoggedIn();
    if (loggedIn) {
      _userData = SessionManager.getUserData() ?? {};
    }
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  void _logout() async {
    await SessionManager.logout();
    _checkLoginStatus();
  }

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())).then((_) => _checkLoginStatus());
  }

  void _navigateToSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())).then((_) => _checkLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(
              "assets/images/banner5.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.purple.withOpacity(0.1)),
            ),
          ),
          _isLoggedIn ? _buildLoggedInUI() : _buildLoggedOutUI(),
        ],
      ),
    );
  }

  Widget _buildLoggedOutUI() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset("assets/images/logo3.png", height: 100),
          const SizedBox(height: 30),
          const Text("Welcome to Namaste Grocer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text("Please login or create an account to manage your orders, addresses, and preferences", style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _navigateToLogin,
              child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Colors.purple),
              ),
              onPressed: _navigateToSignup,
              child: const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white.withOpacity(0.8),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.purple, child: Icon(Icons.person, size: 30, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userData['name'] ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (_userData['email'] != null)
                        Text(_userData['email'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      if (_userData['phone'] != null)
                        Text(_userData['phone'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 0),
          _buildAccountOption(
            icon: Icons.shopping_bag_outlined,
            title: "My Orders",
            subtitle: "Check your order status",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage())),
          ),
          _buildAccountOption(
            icon: Icons.location_on_outlined,
            title: "My Addresses",
            subtitle: "Manage your delivery addresses",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageAddressesPage())),
          ),
          _buildAccountOption(
            icon: Icons.favorite_border,
            title: "My Favorites",
            subtitle: "View your favorite products",
            onTap: () => widget.onNavigateToTab(3),
          ),
          const SizedBox(height: 12),
          _buildAccountOption(
            icon: Icons.security_outlined,
            title: "Privacy & Security",
            subtitle: "Manage your account security",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),
          ),
          _buildAccountOption(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "Get help with your account",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withOpacity(0.8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      color: Colors.white.withOpacity(0.8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        leading: Icon(icon, color: Colors.purple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}