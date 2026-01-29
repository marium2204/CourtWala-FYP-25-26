import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class AddEditCourtScreen extends StatefulWidget {
  const AddEditCourtScreen({super.key});

  @override
  State<AddEditCourtScreen> createState() => _AddEditCourtScreenState();
}

class _AddEditCourtScreenState extends State<AddEditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _loadingSports = true;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _priceController = TextEditingController();
  final _mapUrlController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<File> _pickedImages = [];

  final Map<String, bool> _amenities = {
    'Parking': false,
    'Indoor Lights': false,
    'Shower': false,
    'Equipment Rental': false,
  };

  final List<Map<String, String>> _slots = [];

  /// 🔥 SPORTS FROM BACKEND
  List<Map<String, dynamic>> _sports = [];
  final Set<String> _selectedSportIds = {};

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  /* ================= LOAD SPORTS ================= */

  Future<void> _loadSports() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/sports', token);
      final body = jsonDecode(res.body);

      setState(() {
        _sports = List<Map<String, dynamic>>.from(body['data']);
        _loadingSports = false;
      });
    } catch (_) {
      setState(() => _loadingSports = false);
    }
  }

  /* ================= IMAGE PICKER ================= */

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _pickedImages.add(File(image.path)));
    }
  }

  /* ================= SLOT PICKER ================= */

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

    setState(() {
      _slots.add({
        'startTime': _to24Hour(start),
        'endTime': _to24Hour(end),
      });
    });
  }

  String _to24Hour(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isValidGoogleMapsUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    const allowedHosts = [
      'www.google.com',
      'google.com',
      'maps.google.com',
      'goo.gl',
      'maps.app.goo.gl',
    ];

    return allowedHosts.any((host) => uri.host.contains(host));
  }

  /* ================= SUBMIT ================= */

  Future<void> _submitCourt() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one sport')),
      );
      return;
    }

    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one slot')),
      );
      return;
    }

    final token = await TokenService.getToken();
    if (token == null) return;

    setState(() => _submitting = true);

    try {
      final res = await ApiService.multipartPost(
        '/owner/courts',
        token,
        {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipController.text.trim(),
          'mapUrl': _mapUrlController.text.trim(),
          'pricePerHour': _priceController.text.trim(),
          'sports': jsonEncode(_selectedSportIds.toList()),
          'amenities': jsonEncode(
            _amenities.entries.where((e) => e.value).map((e) => e.key).toList(),
          ),
        },
        files: _pickedImages,
        fileField: 'images',
      );

      final body = jsonDecode(res.body);
      final courtId = body['data']['id'];

      await ApiService.post(
        '/owner/courts/$courtId/slots',
        token,
        {'slots': _slots},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Court submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Court', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Court Details'),
              _field(_nameController, 'Court Name'),
              _field(_descriptionController, 'Description', maxLines: 3),
              _field(_addressController, 'Address'),
              _rowFields(_cityController, 'City', _stateController, 'State'),
              _rowFields(
                _zipController,
                'Zip Code',
                _priceController,
                'Price per hour',
                keyboardType2: TextInputType.number,
              ),
              _field(
                _mapUrlController,
                'Google Maps URL',
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!_isValidGoogleMapsUrl(v))
                    return 'Invalid Google Maps URL';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _section('Sports'),
              _sportsSelector(),
              const SizedBox(height: 20),
              _section('Images'),
              _imagePicker(),
              const SizedBox(height: 20),
              _section('Amenities'),
              _amenitiesChips(),
              const SizedBox(height: 20),
              _section('Time Slots'),
              ..._slots.map(
                (s) => ListTile(
                  title: Text('${s['startTime']} - ${s['endTime']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _slots.remove(s)),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add),
                label: const Text('Add Slot'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitCourt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Court',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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

  Widget _section(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.sectionTitle));

  Widget _field(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator ??
              (v) => v == null || v.isEmpty ? 'Enter $label' : null,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  Widget _rowFields(
    TextEditingController c1,
    String l1,
    TextEditingController c2,
    String l2, {
    TextInputType keyboardType2 = TextInputType.text,
  }) =>
      Row(
        children: [
          Expanded(child: _field(c1, l1)),
          const SizedBox(width: 12),
          Expanded(child: _field(c2, l2, keyboardType: keyboardType2)),
        ],
      );

  Widget _sportsSelector() {
    if (_loadingSports) {
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

  Widget _imagePicker() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            children: _pickedImages
                .map((f) =>
                    Image.file(f, width: 80, height: 80, fit: BoxFit.cover))
                .toList(),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Add Image'),
          ),
        ],
      );

  Widget _amenitiesChips() => Wrap(
        spacing: 10,
        children: _amenities.keys.map((k) {
          final selected = _amenities[k]!;
          return FilterChip(
            label: Text(k),
            selected: selected,
            selectedColor: AppColors.primaryColor,
            onSelected: (v) => setState(() => _amenities[k] = v),
          );
        }).toList(),
      );
}
