import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/session_manager.dart';
import 'add_new_address.dart';

enum AddressAction { edit, delete }

class ManageAddressesPage extends StatefulWidget {
  const ManageAddressesPage({super.key});

  @override
  State<ManageAddressesPage> createState() => _ManageAddressesPageState();
}

class _ManageAddressesPageState extends State<ManageAddressesPage> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;
  int? _selectedAddressId;
  int? _settingDefaultId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final userData = SessionManager.getUserData();
    final token = SessionManager.getToken();
    if (userData == null || token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final userId = userData['id'];
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://13.127.232.90:8084/address/user/$userId'),
        headers: {'Authorization': token},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          setState(() {
            _addresses = data['data'];
            final defaultAddress = _addresses.firstWhere(
                    (addr) => addr['default'] == true,
                orElse: () => null);
            _selectedAddressId = defaultAddress?['id'];
          });
        }
      }
    } catch (e) {
      print("Error fetching addresses: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteAddress(int addressId) async {
    final token = SessionManager.getToken();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://13.127.232.90:8084/address/$addressId'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        _fetchAddresses();
      }
    } catch (e) {
      print("Error deleting address: $e");
    }
  }

  Future<void> _setDefaultAddress(Map<String, dynamic> address) async {
    final int addressId = address['id'];
    final token = SessionManager.getToken();
    if (token == null) return;

    setState(() {
      _settingDefaultId = addressId;
    });

    try {
      final response = await http.put(
        Uri.parse('http://13.127.232.90:8084/address/address/set-default/$addressId'),
        headers: {'Authorization': token},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            for (var addr in _addresses) {
              addr['default'] = (addr['id'] == addressId);
            }
            _selectedAddressId = addressId;
          });
          Navigator.pop(context, address);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Failed to set default address.")),
          );
        }
      } else {
        print("Set Default API Failed with Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to set default address.")),
        );
      }
    } catch (e) {
      print("Error setting default address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _settingDefaultId = null;
        });
      }
    }
  }

  void _navigateAndModifyAddress({Map<String, dynamic>? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddNewAddressPage(addressToEdit: address)),
    );
    if (result == true) {
      _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAddresses,
        child: _addresses.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: _addresses.length,
          itemBuilder: (context, index) {
            final address = _addresses[index];
            return _buildAddressCard(address);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndModifyAddress(),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New Address',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No Addresses Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Text("Add a new address to get started.", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final bool isSelected = _selectedAddressId == address['id'];
    final bool isDefault = address['default'] == true;
    final bool isSetting = _settingDefaultId == address['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.purple : Colors.grey.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: isSetting
                  ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)))
                  : Radio<int>(
                value: address['id'],
                groupValue: _selectedAddressId,
                onChanged: (value) async {
                  await _setDefaultAddress(address);
                },
                activeColor: Colors.purple,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("${address['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Default', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${address['flatNumber']}, ${address['address']}, ${address['city']}, ${address['stateName'] ?? ''} - ${address['pincode']}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text("Mobile: ${address['mobileNumber']}", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _navigateAndModifyAddress(address: address),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteAddress(address['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}