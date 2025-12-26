import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
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

  // ================= SLOT STATE =================

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
      // 1️⃣ CREATE COURT
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

      // 2️⃣ CREATE SLOTS
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
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Add Court', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _field(_nameController, 'Court Name'),
            _field(_descriptionController, 'Description', maxLines: 3),
            _field(_addressController, 'Address'),
            _field(_cityController, 'City'),
            _field(_stateController, 'State'),
            _field(_zipController, 'Zip Code'),
            _field(_priceController, 'Price per hour (PKR)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _sportSelector(),
            const SizedBox(height: 16),
            _imagePicker(),
            const SizedBox(height: 16),
            _amenitiesChips(),
            const SizedBox(height: 24),
            const Text(
              'Available Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._slots.map((s) => ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('${s['startTime']} - ${s['endTime']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _slots.remove(s)),
                  ),
                )),
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
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
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
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _sportSelector() {
    final sports = ['Badminton', 'Cricket', 'Football', 'Padel'];
    return Wrap(
      spacing: 10,
      children: sports.map((s) {
        return ChoiceChip(
          label: Text(s),
          selected: _selectedSport == s,
          selectedColor: AppColors.primaryColor,
          labelStyle: TextStyle(
              color: _selectedSport == s ? Colors.white : Colors.black),
          onSelected: (_) => setState(() => _selectedSport = s),
        );
      }).toList(),
    );
  }

  Widget _imagePicker() {
    return Column(
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
  }

  Widget _amenitiesChips() {
    return Wrap(
      spacing: 10,
      children: _amenities.keys.map((k) {
        return FilterChip(
          label: Text(k),
          selected: _amenities[k]!,
          selectedColor: AppColors.primaryColor,
          labelStyle:
              TextStyle(color: _amenities[k]! ? Colors.white : Colors.black),
          onSelected: (v) => setState(() => _amenities[k] = v),
        );
      }).toList(),
    );
  }
}
