// lib/Player_Panel/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController =
      TextEditingController(text: "John Doe");
  final TextEditingController _emailController =
      TextEditingController(text: "john@example.com");
  final TextEditingController _phoneController =
      TextEditingController(text: "+92 300 1234567");

  String _selectedSport = "Badminton";
  String _selectedLevel = "Intermediate";

  final List<String> sports = ["Badminton", "Cricket", "Football", "Padel"];
  final List<String> levels = ["Beginner", "Intermediate", "Advanced"];

  File? _avatarFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Handle saving the data (to backend or Firebase)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context); // Go back to ProfileScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar with edit button
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.accentColor,
                    backgroundImage:
                        _avatarFile != null ? FileImage(_avatarFile!) : null,
                    child: _avatarFile == null
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryColor,
                      child:
                          const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter your name"
                    : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter your email";
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                    return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter your phone number"
                    : null,
              ),
              const SizedBox(height: 12),

              // Sport Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSport,
                items: sports
                    .map((sport) =>
                        DropdownMenuItem(value: sport, child: Text(sport)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: "Sport",
                  prefixIcon: const Icon(Icons.sports),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                onChanged: (value) => setState(() => _selectedSport = value!),
              ),
              const SizedBox(height: 12),

              // Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                items: levels
                    .map((level) =>
                        DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: "Level",
                  prefixIcon: const Icon(Icons.star),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
