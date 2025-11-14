import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:image_picker/image_picker.dart';

class OwnerEditProfileScreen extends StatefulWidget {
  const OwnerEditProfileScreen({super.key});

  @override
  State<OwnerEditProfileScreen> createState() => _OwnerEditProfileScreenState();
}

class _OwnerEditProfileScreenState extends State<OwnerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "Court Owner Name";
  String email = "owner@email.com";
  String phone = "0300-1234567";
  String courts = "3";
  String address = "City, Country";

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== PROFILE PICTURE =====
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.accentColor,
                      backgroundImage:
                          _avatarFile != null ? FileImage(_avatarFile!) : null,
                      child: _avatarFile == null
                          ? const Icon(Icons.person,
                              size: 55, color: Colors.white)
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor,
                      child:
                          const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ===== INPUT FIELDS =====
              _buildTextField(
                  label: "Name",
                  icon: Icons.person,
                  initialValue: name,
                  onSaved: (val) => name = val!),
              const SizedBox(height: 16),
              _buildTextField(
                  label: "Email",
                  icon: Icons.email,
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val!),
              const SizedBox(height: 16),
              _buildTextField(
                  label: "Phone",
                  icon: Icons.phone,
                  initialValue: phone,
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => phone = val!),
              const SizedBox(height: 16),
              _buildTextField(
                  label: "Number of Courts",
                  icon: Icons.sports_tennis,
                  initialValue: courts,
                  keyboardType: TextInputType.number,
                  onSaved: (val) => courts = val!),
              const SizedBox(height: 16),
              _buildTextField(
                  label: "Address",
                  icon: Icons.location_on,
                  initialValue: address,
                  onSaved: (val) => address = val!),
              const SizedBox(height: 32),

              // ===== SAVE BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile Updated")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Save Changes",
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: AppColors.primaryColor.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Enter $label" : null,
      onSaved: onSaved,
    );
  }
}
