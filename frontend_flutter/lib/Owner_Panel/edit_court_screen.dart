import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class EditCourtScreen extends StatefulWidget {
  final Map<String, dynamic> court;

  const EditCourtScreen({super.key, required this.court});

  @override
  State<EditCourtScreen> createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _priceCtrl;

  String _sport = 'BADMINTON';
  bool isLoading = false;
  bool loadingSlots = true;

  final List<File> newImages = [];
  final List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.court['name'] ?? '');
    _addressCtrl = TextEditingController(text: widget.court['address'] ?? '');
    _priceCtrl = TextEditingController(
      text: widget.court['pricePerHour']?.toString() ?? '',
    );

    _sport = widget.court['sport'] ?? 'BADMINTON';
    _fetchSlots();
  }

  String _to24(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchSlots() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.get(
        '/owner/courts/${widget.court['id']}/slots',
        token,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _slots
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(body['slots']));
        });
      }
    } catch (e) {
      debugPrint('Fetch slots error: $e');
    } finally {
      if (mounted) setState(() => loadingSlots = false);
    }
  }

  Future<void> _addSlot() async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: start.replacing(hour: start.hour + 1),
    );
    if (end == null) return;

    final token = await TokenService.getToken();
    if (token == null) return;

    final res = await ApiService.post(
      '/owner/courts/${widget.court['id']}/slots',
      token,
      {
        'slots': [
          {
            'startTime': _to24(start),
            'endTime': _to24(end),
          }
        ]
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      _fetchSlots();
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.delete(
        '/owner/courts/${widget.court['id']}/slots/$slotId',
        token,
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot deleted')),
        );
        _fetchSlots();
      } else {
        final body = jsonDecode(res.body);
        throw Exception(body['message'] ?? 'Failed to delete slot');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateCourt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final fields = {
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'sport': _sport,
        'pricePerHour': _priceCtrl.text.trim(),
      };

      final res = await ApiService.multipartPut(
        '/owner/courts/${widget.court['id']}',
        token,
        fields,
        files: newImages,
        fileField: 'images',
      );

      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        throw Exception(res.body);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update court')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Edit Court'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _sectionCard(
                      title: 'Court Information',
                      child: Column(
                        children: [
                          _field(_nameCtrl, 'Court Name'),
                          _field(_addressCtrl, 'Address'),
                          _sportSelector(),
                          _field(
                            _priceCtrl,
                            'Price per hour (PKR)',
                            keyboard: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionCard(
                      title: 'Time Slots',
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primaryColor,
                        onPressed: _addSlot,
                      ),
                      child: loadingSlots
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _slots.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'No slots added yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Column(
                                  children: _slots.map((s) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${s['startTime']} - ${s['endTime']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _deleteSlot(s['id']),
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _updateCourt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Update Court',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.backgroundColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF2F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _sportSelector() {
    const sports = {
      'BADMINTON': 'Badminton',
      'CRICKET': 'Cricket',
      'FOOTBALL': 'Football',
      'PADEL': 'Padel',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: sports.entries.map((e) {
          final selected = _sport == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: selected,
            selectedColor: AppColors.primaryColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: selected ? AppColors.primaryColor : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) => setState(() => _sport = e.key),
          );
        }).toList(),
      ),
    );
  }
}
