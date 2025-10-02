import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/session_manager.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderSummary;

  const OrderDetailPage({super.key, required this.orderSummary});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final token = SessionManager.getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication error.";
      });
      return;
    }

    final orderId = widget.orderSummary['id'];
    try {
      final response = await http.get(
        Uri.parse('http://13.127.232.90:8084/order-item/$orderId'),
        headers: {'Authorization': token},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          setState(() => _orderDetails = data['data']);
        } else {
          setState(() => _errorMessage = data['message'] ?? 'Failed to fetch details.');
        }
      } else {
        setState(() => _errorMessage = 'Server error.');
      }
    } catch (e) {
      if(mounted) setState(() => _errorMessage = 'An error occurred.');
    }
    if(mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Order #${widget.orderSummary['orderNumber']}"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
          : _orderDetails == null
          ? const Center(child: Text("Could not load order details."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildItemsCard(_orderDetails!['orderItems'] ?? []),
            const SizedBox(height: 12),
            _buildBillDetailsCard(_orderDetails!['orderResponse'], _orderDetails!['orderItems']),
            const SizedBox(height: 12),
            _buildAddressCard(_orderDetails!['addressResponse']),
            const SizedBox(height: 12),
            _buildPaymentCard(_orderDetails!['orderResponse']),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(List<dynamic> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Items (${items.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item['productImage'] ?? '', width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text("Qty: ${item['quantity']}", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Text("₹${item['totalAmount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard(Map<String, dynamic> order, List<dynamic> items) {
    final double itemsTotal = items.map<double>((item) => (item['totalAmount'] as num).toDouble()).fold(0.0, (a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bill Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildBillRow("Items Total", itemsTotal),
            _buildBillRow("Delivery Fee", (order['shippingAmount'] as num?)?.toDouble() ?? 0.0),
            _buildBillRow("Handling Charge", (order['handlingCharges'] as num?)?.toDouble() ?? 0.0),
            _buildBillRow("Platform Fee", (order['platformCharges'] as num?)?.toDouble() ?? 0.0),
            const Divider(height: 20),
            _buildBillRow("Grand Total", (order['netAmount'] as num?)?.toDouble() ?? 0.0, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[700])),
          Text("₹${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Text(address['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text("${address['flatNumber']}, ${address['address']}, ${address['city']}, ${address['stateName']} - ${address['pincode']}"),
            const SizedBox(height: 4),
            Text("Phone: ${address['mobileNumber']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Payment Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildBillRow("Payment Method", 0), // Placeholder row for layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payment Method", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                Text(order['paymentType'] ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction ID", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                Expanded(child: Text(order['paymentTransactionId'] ?? 'N/A', textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 15))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}