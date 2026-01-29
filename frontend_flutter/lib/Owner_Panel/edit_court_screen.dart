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
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _zipCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _mapUrlCtrl;

  bool isLoading = false;
  bool loadingSlots = true;
  bool loadingSports = true;

  final ImagePicker _picker = ImagePicker();
  final List<File> newImages = [];
  final List<Map<String, dynamic>> _slots = [];

  /// 🔥 SPORTS
  List<Map<String, dynamic>> _sports = [];
  final Set<String> _selectedSportIds = {};

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.court['name'] ?? '');
    _addressCtrl = TextEditingController(text: widget.court['address'] ?? '');
    _cityCtrl = TextEditingController(text: widget.court['city'] ?? '');
    _stateCtrl = TextEditingController(text: widget.court['state'] ?? '');
    _zipCtrl = TextEditingController(text: widget.court['zipCode'] ?? '');
    _priceCtrl =
        TextEditingController(text: widget.court['pricePerHour']?.toString());
    _mapUrlCtrl = TextEditingController(text: widget.court['mapUrl'] ?? '');

    /// preload existing sports
    if (widget.court['sports'] != null) {
      for (final s in widget.court['sports']) {
        _selectedSportIds.add(s['id']);
      }
    }

    _fetchSlots();
    _loadSports();
  }

  /* ================= SPORTS ================= */

  Future<void> _loadSports() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/sports', token);
      final body = jsonDecode(res.body);

      setState(() {
        _sports = List<Map<String, dynamic>>.from(body['data']);
        loadingSports = false;
      });
    } catch (_) {
      setState(() => loadingSports = false);
    }
  }

  /* ================= SLOTS ================= */

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
    } finally {
      if (mounted) setState(() => loadingSlots = false);
    }
  }

  String _to24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _addSlot() async {
    final start =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: start.replacing(hour: start.hour + 1),
    );
    if (end == null) return;

    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.post(
      '/owner/courts/${widget.court['id']}/slots',
      token,
      {
        'slots': [
          {'startTime': _to24(start), 'endTime': _to24(end)}
        ]
      },
    );

    _fetchSlots();
  }

  Future<void> _deleteSlot(String slotId) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.delete(
      '/owner/courts/${widget.court['id']}/slots/$slotId',
      token,
    );

    _fetchSlots();
  }

  /* ================= UPDATE ================= */

  Future<void> _updateCourt() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one sport')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final fields = {
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'zipCode': _zipCtrl.text.trim(),
        'mapUrl': _mapUrlCtrl.text.trim(),
        'pricePerHour': _priceCtrl.text.trim(),
        'sports': jsonEncode(_selectedSportIds.toList()),
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

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Edit Court'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
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
                          _field(_cityCtrl, 'City'),
                          _field(_stateCtrl, 'State'),
                          _field(_zipCtrl, 'Zip Code'),
                          _field(
                            _mapUrlCtrl,
                            'Google Maps URL',
                            keyboard: TextInputType.url,
                          ),
                          const SizedBox(height: 10),
                          _sportsSelector(),
                          _field(
                            _priceCtrl,
                            'Price per hour',
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
                        onPressed: _addSlot,
                      ),
                      child: loadingSlots
                          ? const CircularProgressIndicator()
                          : Column(
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
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _updateCourt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Update Court',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /* ================= HELPERS ================= */

  Widget _sectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (trailing != null) trailing,
          ]),
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

  Widget _sportsSelector() {
    if (loadingSports) {
      return const CircularProgressIndicator();
    }

    return Wrap(
      spacing: 10,
      children: _sports.map((s) {
        final selected = _selectedSportIds.contains(s['id']);
        return FilterChip(
          label: Text(s['name']),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          onSelected: (v) {
            setState(() {
              v
                  ? _selectedSportIds.add(s['id'])
                  : _selectedSportIds.remove(s['id']);
            });
          },
        );
      }).toList(),
    );
  }
}
