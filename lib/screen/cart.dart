import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/cart_manager.dart';
import '../utils/session_manager.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import 'manage_addresses.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _currentIndex = 2;
  final CartManager _cartManager = CartManager();

  Map<String, dynamic>? _deliveryAddress;
  bool _isLoadingAddress = true;
  double _selectedTip = 0.0;
  int _selectedTipIndex = -1;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
    _fetchDefaultAddress();
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchDefaultAddress() async {
    if (!SessionManager.isLoggedIn()) {
      setState(() => _isLoadingAddress = false);
      return;
    }

    final String? token = SessionManager.getToken();
    if (token == null) {
      setState(() => _isLoadingAddress = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://13.127.232.90:8084/address/address/default'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          setState(() => _deliveryAddress = data['data']);
        }
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
    setState(() => _isLoadingAddress = false);
  }

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    NavigationHelper.navigateToPage(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final double itemsTotal = _cartManager.totalPrice;
    const double deliveryCharges = 25.0;
    const double handlingCharges = 10.0;
    const double platformCharges = 10.0;
    final double grandTotal = itemsTotal + deliveryCharges + handlingCharges + platformCharges + _selectedTip;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Cart (${_cartManager.totalItems})"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              NavigationHelper.navigateToPage(context, 0);
            }
          }),
        ],
      ),
      body: _cartManager.items.isEmpty
          ? _buildEmptyCart()
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCartItemsList(),
                const SizedBox(height: 8),
                _buildBillDetails(itemsTotal, grandTotal),
                const SizedBox(height: 8),
                _buildTipSection(),
                const SizedBox(height: 8),
                _buildCancellationPolicy(),
                const SizedBox(height: 8),
                _buildDeliveryAddress(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPayNowButton(grandTotal),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Your Cart is Empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text("Looks like you haven't added anything yet.", style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => NavigationHelper.navigateToPage(context, 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Continue Shopping"),
          )
        ],
      ),
    );
  }

  Widget _buildCartItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cartManager.items.length,
      itemBuilder: (context, index) {
        final cartItem = _cartManager.items[index];
        final product = cartItem['product'];
        final quantity = cartItem['quantity'];
        final productId = product['id'];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    (product['imageUrl'] != null && product['imageUrl'].isNotEmpty) ? product['imageUrl'][0] : '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('₹${product['price']}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: Colors.purple, size: 18), onPressed: () => _cartManager.removeItem(productId)),
                      Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                      IconButton(icon: const Icon(Icons.add, color: Colors.purple, size: 18), onPressed: () => _cartManager.addItem(product)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillDetails(double itemsTotal, double grandTotal) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bill Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildBillRow(Icons.list_alt, "Items total", itemsTotal),
            _buildBillRow(Icons.delivery_dining, "Delivery Charges", 25.0),
            _buildBillRow(Icons.support_agent, "Handling Charges", 10.0),
            _buildBillRow(Icons.desktop_mac, "Platform Charges", 10.0),
            if (_selectedTip > 0) _buildBillRow(Icons.favorite, "Tip for delivery partner", _selectedTip),
            const Divider(height: 24),
            _buildBillRow(Icons.receipt_long, "Grand Total", grandTotal, isGrandTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(IconData icon, String label, double amount, {bool isGrandTotal = false}) {
    final style = TextStyle(
      fontSize: isGrandTotal ? 18 : 15,
      fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: style)),
          Text("₹${amount.toStringAsFixed(2)}", style: style),
        ],
      ),
    );
  }

  Widget _buildTipSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tip your delivery partner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_selectedTip > 0) TextButton(onPressed: () => setState(() { _selectedTip = 0.0; _selectedTipIndex = -1; }), child: const Text("Clear")),
              ],
            ),
            const SizedBox(height: 4),
            Text("Your kindness means a lot! 100% of your tip will go directly to your delivery partner.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTipButton(20.0, 0),
                _buildTipButton(30.0, 1),
                _buildTipButton(50.0, 2),
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Custom"))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipButton(double amount, int index) {
    bool isSelected = _selectedTipIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton(
          onPressed: () => setState(() { _selectedTip = amount; _selectedTipIndex = index; }),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.purple.shade100 : Colors.grey[200],
            foregroundColor: isSelected ? Colors.purple : Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text("₹${amount.toInt()}"),
        ),
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cancellation Policy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Orders cannot be cancelled once packed for delivery. In case of unexpected delays, a refund will be provided, if applicable.", style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingAddress
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    // YAHAN BADLAAV KIYA GAYA HAI
                    final selectedAddress = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageAddressesPage()),
                    );
                    if (selectedAddress != null) {
                      setState(() {
                        _deliveryAddress = selectedAddress;
                      });
                    }
                  },
                  child: const Text("Change"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _deliveryAddress == null
                ? Center(child: TextButton(onPressed: () {}, child: const Text("Add Delivery Address")))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_deliveryAddress!['name']} (${_deliveryAddress!['addressType']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("+91 ${_deliveryAddress!['mobileNumber']}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  "${_deliveryAddress!['flatNumber']}, ${_deliveryAddress!['address']}, ${_deliveryAddress!['city']}, ${_deliveryAddress!['stateName']} - ${_deliveryAddress!['pincode']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayNowButton(double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('View detailed bill', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w500)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pay Now', style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}