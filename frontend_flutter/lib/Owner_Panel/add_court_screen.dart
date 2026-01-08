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

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedSport = 'Badminton';
  final ImagePicker _picker = ImagePicker();
  final List<File> _pickedImages = [];

  final Map<String, bool> _amenities = {
    'Parking': false,
    'Indoor Lights': false,
    'Shower': false,
    'Equipment Rental': false,
  };

  final List<Map<String, String>> _slots = [];

  // ================= IMAGE PICKER =================

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _pickedImages.add(File(image.path)));
    }
  }

  // ================= SLOT PICKER =================

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

  String _to24Hour(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ================= SUBMIT =================

  Future<void> _submitCourt() async {
    if (!_formKey.currentState!.validate()) return;

    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one slot')),
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
          'sport': _selectedSport,
          'pricePerHour': _priceController.text.trim(),
          'amenities': jsonEncode(
            _amenities.entries.where((e) => e.value).map((e) => e.key).toList(),
          ),
        },
        files: _pickedImages,
        fileField: 'images',
      );

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception(res.body);
      }

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
          content: Text('Court & slots submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ================= UI =================

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
              _rowFields(
                _cityController,
                'City',
                _stateController,
                'State',
              ),
              _rowFields(
                _zipController,
                'Zip Code',
                _priceController,
                'Price per hour (PKR)',
                keyboardType2: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _section('Sport'),
              _sportSelector(),
              const SizedBox(height: 20),
              _section('Images'),
              _imagePicker(),
              const SizedBox(height: 20),
              _section('Amenities'),
              _amenitiesChips(),
              const SizedBox(height: 24),
              _section('Available Time Slots'),
              const SizedBox(height: 8),
              ..._slots.map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.schedule, color: AppColors.primaryColor),
                  title: Text(
                    '${s['startTime']} - ${s['endTime']}',
                    style: AppTextStyles.subtitle,
                  ),
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
              const SizedBox(height: 32),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: AppTextStyles.sectionTitle),
      );

  Widget _field(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
        ),
      ),
    );
  }

  Widget _rowFields(
    TextEditingController c1,
    String l1,
    TextEditingController c2,
    String l2, {
    TextInputType keyboardType1 = TextInputType.text,
    TextInputType keyboardType2 = TextInputType.text,
  }) {
    return Row(
      children: [
        Expanded(child: _field(c1, l1, keyboardType: keyboardType1)),
        const SizedBox(width: 12),
        Expanded(child: _field(c2, l2, keyboardType: keyboardType2)),
      ],
    );
  }

  Widget _sportSelector() {
    final sports = ['Badminton', 'Cricket', 'Football', 'Padel'];
    return Wrap(
      spacing: 10,
      children: sports.map((s) {
        final selected = _selectedSport == s;
        return ChoiceChip(
          label: Text(
            s,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          backgroundColor: AppColors.white,
          onSelected: (_) => setState(() => _selectedSport = s),
        );
      }).toList(),
    );
  }

  Widget _imagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pickedImages
              .map(
                (f) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      Image.file(f, width: 90, height: 90, fit: BoxFit.cover),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Add Image'),
        ),
      ],
    );
  }

  Widget _amenitiesChips() {
    return Wrap(
      spacing: 10,
      children: _amenities.keys.map((k) {
        final selected = _amenities[k]!;
        return FilterChip(
          label: Text(
            k,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          backgroundColor: AppColors.white,
          onSelected: (v) => setState(() => _amenities[k] = v),
        );
      }).toList(),
    );
  }
}
