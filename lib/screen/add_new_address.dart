import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/session_manager.dart';

class AddNewAddressPage extends StatefulWidget {
  final Map<String, dynamic>? addressToEdit;

  const AddNewAddressPage({super.key, this.addressToEdit});

  @override
  State<AddNewAddressPage> createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _flatController = TextEditingController();
  final _floorController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedAddressType = 'HOME';
  int? _selectedStateId;
  bool _isLoading = false;
  bool _isLoadingStates = true;

  List<Map<String, dynamic>> _states = [];

  bool get isEditMode => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    try {
      final response = await http.get(Uri.parse('http://13.127.232.90:8084/generic/state/getAll'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          _states = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoadingStates = false);
    _populateFieldsForEdit();
  }

  void _populateFieldsForEdit() {
    if (isEditMode) {
      final address = widget.addressToEdit!;
      _nameController.text = address['name'] ?? '';
      _mobileController.text = address['mobileNumber'] ?? '';
      _flatController.text = address['flatNumber'] ?? '';
      _floorController.text = address['floorNumber'] ?? '';
      _addressController.text = address['address'] ?? '';
      _cityController.text = address['city'] ?? '';
      _pincodeController.text = address['pincode'] ?? '';
      _selectedAddressType = address['addressType'] ?? 'HOME';
      _selectedStateId = address['stateId'];
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = SessionManager.getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final url = isEditMode
        ? 'http://13.127.232.90:8084/address/update'
        : 'http://13.127.232.90:8084/address/save';

    final body = {
      "name": _nameController.text,
      "mobileNumber": _mobileController.text,
      "flatNumber": _flatController.text,
      "floorNumber": _floorController.text,
      "address": _addressController.text,
      "city": _cityController.text,
      "pincode": _pincodeController.text,
      "stateId": _selectedStateId,
      "addressType": _selectedAddressType,
      "landmark": "",
    };

    if (isEditMode) {
      body['id'] = widget.addressToEdit!['id'];
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          if (mounted) Navigator.pop(context, true);
        }
      }
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditMode ? 'Update Address' : 'Add New Address'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingStates
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Address Type',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTypeChip('HOME', Icons.home_outlined),
                    _buildTypeChip('OFFICE', Icons.work_outline),
                    _buildTypeChip('OTHER', Icons.more_horiz),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Contact Details',
                child: Column(
                  children: [
                    _buildTextField(_nameController, "Name", Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_mobileController, "Mobile Number", Icons.phone_iphone, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Address Details',
                child: Column(
                  children: [
                    _buildTextField(_flatController, "Flat, House no., Building", Icons.apartment_outlined),
                    const SizedBox(height: 16),
                    _buildTextField(_addressController, "Area, Street, Sector, Village", Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildTextField(_cityController, "Town/City", Icons.location_city)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedStateId,
                      menuMaxHeight: 250.0,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      items: _states.map((state) {
                        return DropdownMenuItem<int>(value: state['id'], child: Text(state['name']));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedStateId = value),
                      validator: (value) => value == null ? 'Please select a state' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(isEditMode ? 'Update Address' : 'Save Address', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon) {
    bool isSelected = _selectedAddressType == type;
    return ChoiceChip(
      label: Text(type),
      avatar: Icon(icon, color: isSelected ? Colors.purple : Colors.grey[600]),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedAddressType = type);
      },
      selectedColor: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: isSelected ? Colors.purple : Colors.grey.shade300),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
    );
  }
}