import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  bool _loading = true;
  List<dynamic> _bankDetails = [];

  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBankDetails();
  }

  Future<void> _fetchBankDetails() async {
    setState(() => _loading = true);
    try {
      final token = await TokenService.getToken();
      if (token == null) return;
      final res = await ApiService.get('/owner/bank-details', token);
      final data = jsonDecode(res.body);
      if (data['success']) {
        setState(() => _bankDetails = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching banks: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveBank() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final token = await TokenService.getToken();
      if (token == null) return;
      
      final res = await ApiService.post('/owner/bank-details', token, {
        'provider': _providerController.text,
        'accountName': _accountNameController.text,
        'accountNumber': _accountNumberController.text,
        'isActive': true,
      });
      
      if (res.statusCode == 201) {
        _providerController.clear();
        _accountNameController.clear();
        _accountNumberController.clear();
        Navigator.pop(context);
        _fetchBankDetails();
      }
    } catch (e) {
      debugPrint("Error saving bank: $e");
    }
  }

  Future<void> _toggleActive(String id, bool currentStatus) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;
      await ApiService.put('/owner/bank-details/$id', token, {'isActive': !currentStatus});
      _fetchBankDetails();
    } catch (e) {
      debugPrint("Error toggling: $e");
    }
  }

  Future<void> _deleteBank(String id) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;
      await ApiService.delete('/owner/bank-details/$id', token);
      _fetchBankDetails();
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Add Payment Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(labelText: "Bank / Provider (e.g. JazzCash)", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: "Account Title", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Account Number", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveBank,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("Save Account", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text("My Bank Details", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _bankDetails.isEmpty 
          ? const Center(child: Text("No bank details added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bankDetails.length,
              itemBuilder: (_, i) {
                final b = _bankDetails[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(b['accountNumber'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
                    subtitle: Text("${b['provider']} • ${b['accountName']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: b['isActive'] ?? true,
                          activeColor: AppColors.primaryColor,
                          onChanged: (_) => _toggleActive(b['id'], b['isActive'] ?? true),
                        ),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBank(b['id'])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
