import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class AddEditCourtScreen extends StatefulWidget {
  final Map<String, dynamic>? court; // If null → add new, else edit

  const AddEditCourtScreen({super.key, this.court});

  @override
  State<AddEditCourtScreen> createState() => _AddEditCourtScreenState();
}

class _AddEditCourtScreenState extends State<AddEditCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _priceController;

  String _selectedSport = 'Badminton';
  String? _selectedAssetImage;
  File? _pickedImage;

  Map<String, bool> _amenities = {
    'Parking': false,
    'Indoor Lights': false,
    'Shower': false,
    'Equipment Rental': false,
  };

  bool _isActive = true; // Only for approved courts
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final court = widget.court;
    _nameController = TextEditingController(text: court?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: court?['description'] ?? '');
    _addressController = TextEditingController(text: court?['address'] ?? '');
    _cityController = TextEditingController(text: court?['city'] ?? '');
    _stateController = TextEditingController(text: court?['state'] ?? '');
    _zipController = TextEditingController(text: court?['zipCode'] ?? '');
    _priceController =
        TextEditingController(text: court?['pricePerHour']?.toString() ?? '');
    _selectedSport = court?['sport'] ?? 'Badminton';
    _selectedAssetImage = court?['image'];
    _amenities = Map<String, bool>.from(court?['amenitiesMap'] ??
        {
          'Parking': false,
          'Indoor Lights': false,
          'Shower': false,
          'Equipment Rental': false,
        });
    _isActive = court?['status'] == 'ACTIVE';
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _selectedAssetImage = null; // deselect asset
      });
    }
  }

  void _submitCourt() {
    if (_formKey.currentState!.validate()) {
      final newCourt = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipController.text,
        'sport': _selectedSport,
        'pricePerHour': double.tryParse(_priceController.text) ?? 0,
        'image': _pickedImage?.path ?? _selectedAssetImage,
        'amenities':
            _amenities.entries.where((e) => e.value).map((e) => e.key).toList(),
        'status': widget.court == null
            ? 'PENDING_APPROVAL'
            : (_isActive ? 'ACTIVE' : 'INACTIVE'),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.court == null
              ? "Court submitted for approval!"
              : "Court updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, newCourt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.court != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Court" : "Add New Court",
          style: const TextStyle(color: Colors.white),
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
              // Name
              _buildTextField(_nameController, "Court Name", 3, 100),
              const SizedBox(height: 16),

              // Description
              _buildTextField(_descriptionController, "Description", 0, 500,
                  maxLines: 3, optional: true),
              const SizedBox(height: 16),

              // Address
              _buildTextField(_addressController, "Address", 3, 200),
              const SizedBox(height: 12),
              _buildTextField(_cityController, "City", 2, 100),
              const SizedBox(height: 12),
              _buildTextField(_stateController, "State", 2, 50),
              const SizedBox(height: 12),
              _buildTextField(_zipController, "Zip Code", 5, 10,
                  regex: r'^\d{5}(-\d{4})?$'),
              const SizedBox(height: 16),

              // Sport
              Text("Select Sport", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildSportSelector(),
              const SizedBox(height: 16),

              // Price
              _buildTextField(
                  _priceController, "Price per hour (PKR)", 1, 999999,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Images
              Text("Select Image", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildImagePicker(),
              const SizedBox(height: 12),
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

              // Amenities
              Text("Amenities", style: _headingStyle()),
              const SizedBox(height: 8),
              _buildAmenitiesChips(),
              const SizedBox(height: 16),

              // ACTIVE / INACTIVE toggle (only for editing)
              if (isEditing)
                Row(
                  children: [
                    const Text("Status:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Switch(
                        value: _isActive,
                        activeColor: AppColors.primaryColor,
                        onChanged: (val) {
                          setState(() => _isActive = val);
                        }),
                    Text(_isActive ? "ACTIVE" : "INACTIVE")
                  ],
                ),

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
                  ),
                  child: Text(
                    isEditing ? "Update Court" : "Submit Court",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
      int minLength, int maxLength,
      {TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      String? regex,
      bool optional = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (val) {
        if (optional && (val == null || val.isEmpty)) return null;
        if (val == null || val.isEmpty) return "Please enter $label";
        if (val.length < minLength)
          return "$label should be at least $minLength characters";
        if (val.length > maxLength)
          return "$label should be at most $maxLength characters";
        if (regex != null && !RegExp(regex).hasMatch(val))
          return "Invalid $label format";
        return null;
      },
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

  Widget _buildAmenitiesChips() {
    return Wrap(
      spacing: 12,
      children: _amenities.keys.map((facility) {
        bool selected = _amenities[facility]!;
        return FilterChip(
          label: Text(facility),
          selected: selected,
          selectedColor: AppColors.primaryColor,
          backgroundColor: Colors.grey[200],
          labelStyle:
              TextStyle(color: selected ? Colors.white : Colors.black87),
          onSelected: (val) => setState(() => _amenities[facility] = val),
        );
      }).toList(),
    );
  }
}
