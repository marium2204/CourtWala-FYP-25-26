import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';
import '../services/image_upload_service.dart';

class EditCourtScreen extends StatefulWidget {
  final Map<String, dynamic> court;
  const EditCourtScreen({super.key, required this.court});

  @override
  State<EditCourtScreen> createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- CONTROLLERS ----------------
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _mapUrlCtrl;
  late TextEditingController _amenitiesCtrl;

  bool isLoading = false;
  bool loadingSports = true;
  bool loadingSlots = true;

  final ImagePicker _picker = ImagePicker();

  /// Cloudinary URLs already saved
  late List<String> existingImages;

  /// New images to upload
  final List<File> newImages = [];

  /// Sports
  List<Map<String, dynamic>> sports = [];
  final Set<String> selectedSportIds = {};

  /// Slots
  List<Map<String, dynamic>> slots = [];
  TimeOfDay? slotStart;
  TimeOfDay? slotEnd;

  String get _imageBaseUrl => ApiConstants.baseUrl.replaceFirst('/api', '');

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.court['name'] ?? '');
    _addressCtrl = TextEditingController(text: widget.court['address'] ?? '');
    _cityCtrl = TextEditingController(text: widget.court['city'] ?? '');
    _priceCtrl =
        TextEditingController(text: widget.court['pricePerHour']?.toString());
    _mapUrlCtrl = TextEditingController(text: widget.court['mapUrl'] ?? '');
    _amenitiesCtrl = TextEditingController(
      text: (widget.court['amenities'] as List?)?.join(', ') ?? '',
    );

    existingImages = (widget.court['images'] as List?)?.cast<String>() ?? [];

    for (final s in widget.court['sports'] ?? []) {
      selectedSportIds.add(s['id']);
    }

    _loadSports();
    _loadSlots();
  }

  // ---------------- LOAD SPORTS ----------------
  Future<void> _loadSports() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    final res = await ApiService.get('/sports', token);
    final body = jsonDecode(res.body);

    setState(() {
      sports = List<Map<String, dynamic>>.from(body['data']);
      loadingSports = false;
    });
  }

  // ---------------- LOAD SLOTS ----------------
  Future<void> _loadSlots() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    final res = await ApiService.get(
      '/owner/courts/${widget.court['id']}/slots',
      token,
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() {
        slots = List<Map<String, dynamic>>.from(body['slots']);
        loadingSlots = false;
      });
    }
  }

  // ---------------- ADD SLOT ----------------
  Future<void> _addSlot() async {
    if (slotStart == null || slotEnd == null) return;

    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.post(
      '/owner/courts/${widget.court['id']}/slots',
      token,
      {
        'slots': [
          {
            'startTime': _fmt(slotStart!),
            'endTime': _fmt(slotEnd!),
          }
        ]
      },
    );

    slotStart = null;
    slotEnd = null;
    await _loadSlots();
  }

  // ---------------- DELETE SLOT ----------------
  Future<void> _deleteSlot(String slotId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await ApiService.delete(
        '/owner/courts/${widget.court['id']}/slots/$slotId',
        token,
      );

      await _loadSlots();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot has active bookings and cannot be deleted'),
        ),
      );
    }
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => newImages.add(File(x.path)));
  }

  // ---------------- UPDATE COURT ----------------
  Future<void> _updateCourt() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one sport')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      // 1. Upload new images to Cloudinary
      final List<String> uploadedUrls = [];
      for (final file in newImages) {
        final url = await ImageUploadService.uploadToCloudinary(
          file,
          folder: 'courtwala/courts',
        );
        if (url != null) uploadedUrls.add(url);
      }

      // 2. Combine with existing
      final finalImages = [...existingImages, ...uploadedUrls];

      // 3. Send JSON PUT request
      final res = await ApiService.put(
        '/owner/courts/${widget.court['id']}',
        token,
        {
          'name': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'mapUrl': _mapUrlCtrl.text.trim(),
          'pricePerHour': _priceCtrl.text.trim(),
          'sports': selectedSportIds.toList(),
          'amenities': _amenitiesCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'existingImages': finalImages, // Send the full list
          'images': [], // Clear the file field
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Court updated successfully"),
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to update court')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _section(
                        'Court Details',
                        Column(children: [
                          _input(_nameCtrl, 'Court Name'),
                          _input(_addressCtrl, 'Address'),
                          _input(_cityCtrl, 'City'),
                          _input(_priceCtrl, 'Price / hour',
                              keyboard: TextInputType.number),
                          _input(_mapUrlCtrl, 'Google Maps URL'),
                        ])),
                    _section('Amenities',
                        _input(_amenitiesCtrl, 'Parking, Washroom')),
                    _section(
                      'Sports',
                      loadingSports
                          ? const CircularProgressIndicator()
                          : Wrap(
                              spacing: 8,
                              children: sports.map((s) {
                                final selected =
                                    selectedSportIds.contains(s['id']);
                                return FilterChip(
                                  label: Text(s['name']),
                                  selected: selected,
                                  onSelected: (v) => setState(() {
                                    v
                                        ? selectedSportIds.add(s['id'])
                                        : selectedSportIds.remove(s['id']);
                                  }),
                                );
                              }).toList(),
                            ),
                    ),
                    _section(
                      'Slots',
                      Column(children: [
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                slotStart = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {});
                              },
                              child: Text(slotStart == null
                                  ? 'Start'
                                  : slotStart!.format(context)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                slotEnd = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {});
                              },
                              child: Text(slotEnd == null
                                  ? 'End'
                                  : slotEnd!.format(context)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addSlot,
                          )
                        ]),
                        const SizedBox(height: 12),
                        loadingSlots
                            ? const CircularProgressIndicator()
                            : Column(
                                children: slots.map((s) {
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
                              )
                      ]),
                    ),
                    const SizedBox(height: 24),
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

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _input(TextEditingController c, String label,
          {TextInputType keyboard = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _section(String title, Widget child) => Card(
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}
