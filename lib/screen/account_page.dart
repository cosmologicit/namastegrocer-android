import 'package:flutter/material.dart';
import 'package:sample/screen/privacy_security.dart';
import 'package:sample/screen/help_support.dart';

import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import '../utils/session_manager.dart';
import 'login.dart';
import 'signup.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoggedIn = false;
  Map<String, dynamic> _userData = {};
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    bool loggedIn = SessionManager.isLoggedIn();
    if (loggedIn) {
      _userData = SessionManager.getUserData();
    }
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  void _logout() {
    SessionManager.logout();
    setState(() {
      _isLoggedIn = false;
      _userData = {};
    });
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) => _checkLoginStatus());
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    ).then((_) => _checkLoginStatus());
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
    NavigationHelper.navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ADDED: To remove back button on root screen
      ),
      body: _isLoggedIn ? _buildLoggedInUI() : _buildLoggedOutUI(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildLoggedOutUI() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch, // To stretch buttons
        children: [
          Image.asset(
            "lib/image/logo3.png",
            height: 100,
          ),
          const SizedBox(height: 30),
          const Text(
            "Welcome to Namaste Grocer",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Please login or create an account to manage your orders, addresses, and preferences",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Slightly more rounded
                ),
              ),
              onPressed: _navigateToLogin,
              child: const Text(
                "Login",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Colors.purple),
              ),
              onPressed: _navigateToSignup,
              child: const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_userData['email'] != null)
                        Text(
                          _userData['email'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      if (_userData['phone'] != null)
                        Text(
                          _userData['phone'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                // ADDED: Edit profile icon
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    // TODO: Navigate to Edit Profile page
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1), // ADDED: Visual separator
          const SizedBox(height: 10),
          _buildAccountOption(
            icon: Icons.shopping_bag_outlined,
            title: "My Orders",
            subtitle: "Check your order status",
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.location_on_outlined,
            title: "My Addresses",
            subtitle: "Manage your delivery addresses",
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.favorite_border,
            title: "My Favorites",
            subtitle: "View your favorite products",
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.notifications_none,
            title: "Notifications",
            subtitle: "Manage your notifications",
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.security_outlined,
            title: "Privacy & Security",
            subtitle: "Manage your account security",
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
              );
            },
          ),
          _buildAccountOption(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "Get help with your account",
            // CHANGED: Added navigation
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: _logout,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // REMOVED Card for a flatter design, looks cleaner in a list
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}