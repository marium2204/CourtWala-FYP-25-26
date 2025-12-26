import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  //final ImagePicker _picker = ImagePicker();
  final List<File> newImages = [];

  // ================= SLOT STATE =================
  final List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.court['name'] ?? '');
    _addressCtrl = TextEditingController(text: widget.court['address'] ?? '');
    _priceCtrl = TextEditingController(
        text: widget.court['pricePerHour']?.toString() ?? '');

    _sport = widget.court['sport'] ?? 'BADMINTON';

    _fetchSlots();
  }

  // ================= TIME FORMAT =================
  String _to24(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // ================= FETCH SLOTS =================
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

  // ================= ADD SLOT =================
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

  // ================= DELETE SLOT =================
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

  // ================= UPDATE COURT =================
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update court')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Court', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(_nameCtrl, 'Court Name'),
                    _field(_addressCtrl, 'Address'),
                    _sportSelector(),
                    _field(_priceCtrl, 'Price per hour (PKR)',
                        keyboard: TextInputType.number),
                    const SizedBox(height: 16),
                    const Text('Time Slots',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    loadingSlots
                        ? const CircularProgressIndicator()
                        : _slots.isEmpty
                            ? const Text('No slots added yet')
                            : Card(
                                child: Column(
                                  children: _slots.map((s) {
                                    return ListTile(
                                      title: Text(
                                          '${s['startTime']} - ${s['endTime']}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteSlot(s['id']),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                    TextButton.icon(
                      onPressed: _addSlot,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Slot'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateCourt,
                      child: const Text('Update Court'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
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

    return Wrap(
      spacing: 10,
      children: sports.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value),
          selected: _sport == e.key,
          onSelected: (_) => setState(() => _sport = e.key),
        );
      }).toList(),
    );
  }
}
