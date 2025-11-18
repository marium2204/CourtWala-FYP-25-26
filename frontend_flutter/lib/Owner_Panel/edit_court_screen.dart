import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class EditCourtScreen extends StatefulWidget {
  final Map<String, dynamic> court;
  const EditCourtScreen({super.key, required this.court});

  @override
  State<EditCourtScreen> createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;

  String _selectedSport = 'Badminton';
  String? _selectedAssetImage;
  File? _pickedImage;

  final Map<String, bool> _facilities = {
    'Parking': false,
    'Indoor Lights': false,
    'Shower': false,
    'Equipment Rental': false,
  };

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.court['name']);
    _locationController =
        TextEditingController(text: widget.court['location'] ?? '');
    _priceController = TextEditingController(text: widget.court['price'] ?? '');
    _selectedSport = widget.court['sport'];
    _selectedAssetImage = widget.court['image'];
    if (widget.court['facilities'] != null) {
      for (var key in _facilities.keys) {
        _facilities[key] = widget.court['facilities'].contains(key);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _selectedAssetImage = null;
      });
    }
  }

  void _updateCourt() {
    if (_formKey.currentState!.validate()) {
      final updatedCourt = {
        'name': _nameController.text,
        'location': _locationController.text,
        'sport': _selectedSport,
        'price': _priceController.text,
        'image': _pickedImage?.path ?? _selectedAssetImage,
        'facilities': _facilities.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'rating': widget.court['rating'],
        'bookings': widget.court['bookings'],
      };
      Navigator.pop(context, updatedCourt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Court",
          style: TextStyle(color: Colors.white),
        ),
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
              _buildTextField(_nameController, "Court Name"),
              const SizedBox(height: 16),
              _buildTextField(_locationController, "Location"),
              const SizedBox(height: 16),
              _buildSportSelector(),
              const SizedBox(height: 16),
              _buildTextField(_priceController, "Price per hour (PKR)",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Pick from Gallery"),
                ),
              ),
              const SizedBox(height: 16),
              _buildFacilitiesChips(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCourt,
                  child: const Text(
                    "Update Court",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val!.isEmpty ? "Please enter $label" : null,
    );
  }

  Widget _buildSportSelector() {
    final sports = {
      'Badminton': Icons.sports_tennis,
      'Cricket': Icons.sports_cricket,
      'Football': Icons.sports_soccer,
      'Padel': Icons.sports_tennis,
    };
    return Wrap(
      spacing: 12,
      children: sports.entries.map((entry) {
        bool selected = _selectedSport == entry.key;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.value, color: selected ? Colors.white : Colors.black),
              const SizedBox(width: 6),
              Text(entry.key),
            ],
          ),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          backgroundColor: Colors.grey[200],
          onSelected: (_) => setState(() => _selectedSport = entry.key),
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    final assetImages = [
      'assets/badmintonCourt.jpeg',
      'assets/logo.png',
      'assets/Court.png'
    ];
    return Wrap(
      spacing: 12,
      children: [
        ...assetImages.map((img) {
          bool selected = _selectedAssetImage == img;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAssetImage = img;
                _pickedImage = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: selected ? AppColors.primaryColor : Colors.grey,
                    width: selected ? 3 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Image.asset(img, width: 100, height: 80, fit: BoxFit.cover),
            ),
          );
        }).toList(),
        if (_pickedImage != null)
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.file(_pickedImage!, fit: BoxFit.cover),
          ),
      ],
    );
  }

  Widget _buildFacilitiesChips() {
    return Wrap(
      spacing: 12,
      children: _facilities.keys.map((facility) {
        bool selected = _facilities[facility]!;
        return FilterChip(
          label: Text(facility),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          backgroundColor: Colors.grey[200],
          onSelected: (val) => setState(() => _facilities[facility] = val),
        );
      }).toList(),
    );
  }
}
