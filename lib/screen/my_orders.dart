import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../utils/session_manager.dart';
import 'order_detail.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!SessionManager.isLoggedIn()) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please login to view your orders.";
      });
      return;
    }

    final token = SessionManager.getToken();
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://13.127.232.90:8084/order/get-all-orders-by-user'),
        headers: {'Authorization': token!},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          setState(() {
            _orders = data['data'];
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to fetch orders.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to the server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateFromOrderNumber(String orderNumber) {
    if (orderNumber.length < 8) return orderNumber;
    try {
      final dateString = orderNumber.substring(0, 8);
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return orderNumber;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'COMPLETED':
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
          : _orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("You have no orders yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return _buildOrderCard(order);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final List<dynamic> items = order['orderItems'] ?? [];
    final statusColor = _getStatusColor(order['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailPage(orderSummary: order)),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 8, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${order['orderNumber']}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
                          ),
                          Text(
                            order['status'] ?? 'UNKNOWN',
                            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                      Text(
                        _formatDateFromOrderNumber(order['orderNumber']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Divider(height: 20),
                      if (items.isNotEmpty)
                        SizedBox(
                          height: 50,
                          child: Stack(
                            children: List.generate(
                              items.length > 4 ? 4 : items.length,
                                  (index) {
                                if (index == 3 && items.length > 4) {
                                  return Positioned(
                                    left: index * 40.0,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${items.length - 3}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final item = items[index];
                                final imageUrl = item['productImage'];
                                return Positioned(
                                  left: index * 90.0,
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl ?? ''),
                                        fit: BoxFit.cover,
                                        onError: (e, s) {},
                                      ),
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const Spacer(),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total: ₹${order['netAmount']}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Row(
                            children: [
                              Text(
                                "View Details",
                                style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.purple),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}