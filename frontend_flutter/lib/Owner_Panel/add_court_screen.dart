import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class AddCourtScreen extends StatefulWidget {
  const AddCourtScreen({super.key});

  @override
  State<AddCourtScreen> createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedSport = 'Badminton';
  String? _selectedAssetImage = 'assets/badmintonCourt.jpeg';
  File? _pickedImage;

  Map<String, bool> _facilities = {
    'Parking': false,
    'Indoor Lights': false,
    'Shower': false,
    'Equipment Rental': false,
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _selectedAssetImage = null; // deselect asset image
      });
    }
  }

  void _submitCourt() {
    if (_formKey.currentState!.validate()) {
      final newCourt = {
        'name': _nameController.text,
        'location': _locationController.text,
        'sport': _selectedSport,
        'price': _priceController.text,
        'image': _pickedImage?.path ?? _selectedAssetImage,
        'facilities': _facilities.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'rating': 0.0,
        'bookings': 0,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Court added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, newCourt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          "Add New Court",
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
              // Court Name
              _buildTextField(_nameController, "Court Name"),
              const SizedBox(height: 16),

              // Location
              _buildTextField(_locationController, "Location"),
              const SizedBox(height: 16),

              // Sport Selector
              Text("Select Sport", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildSportSelector(),
              const SizedBox(height: 16),

              // Price
              _buildTextField(_priceController, "Price per hour (PKR)",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Image Picker
              Text("Select Image", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildImagePicker(),
              const SizedBox(height: 16),

              // Pick from Gallery
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Pick from Gallery"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Facilities
              Text("Facilities", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildFacilitiesChips(),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCourt,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primaryColor,
                    shadowColor: Colors.black54,
                    elevation: 6,
                  ),
                  child: const Text(
                    "Add Court",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helper Widgets =====

  TextStyle _headingStyle() =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) => val!.isEmpty ? "Please enter $label" : null,
      ),
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
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
          onSelected: (_) => setState(() => _selectedSport = entry.key),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        // Asset images
        ...assetImages.map((img) {
          bool selected = _selectedAssetImage == img;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAssetImage = img;
                _pickedImage = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(
                    color: selected ? AppColors.primaryColor : Colors.grey,
                    width: selected ? 3 : 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3))
                      ]
                    : [],
              ),
              child:
                  Image.asset(img, width: 100, height: 80, fit: BoxFit.cover),
            ),
          );
        }).toList(),

        // Picked gallery image preview
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
          labelStyle:
              TextStyle(color: selected ? Colors.white : Colors.black87),
          onSelected: (val) => setState(() => _facilities[facility] = val),
        );
      }).toList(),
    );
  }
}
