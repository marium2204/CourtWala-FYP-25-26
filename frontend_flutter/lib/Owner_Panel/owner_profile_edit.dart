import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../theme/colors.dart';
import '../services/token_service.dart';
import '../authentication_screens/splash_screen.dart';

class OwnerEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> owner;

  const OwnerEditProfileScreen({super.key, required this.owner});

  @override
  State<OwnerEditProfileScreen> createState() => _OwnerEditProfileScreenState();
}

class _OwnerEditProfileScreenState extends State<OwnerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final firstName = widget.owner['firstName'] ?? '';
    final lastName = widget.owner['lastName'] ?? '';

    _fullNameController =
        TextEditingController(text: ('$firstName $lastName').trim());
    _emailController = TextEditingController(text: widget.owner['email'] ?? '');
    _phoneController = TextEditingController(text: widget.owner['phone'] ?? '');
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await TokenService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final parts = _fullNameController.text.trim().split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final uri = Uri.parse('http://192.168.1.115:3000/api/owner/profile');

      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phone'] = _phoneController.text.trim();

      if (_avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture', // MUST match backend field name
            _avatarFile!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        debugPrint(response.body);
        throw Exception('Update failed');
      }
    } catch (e) {
      debugPrint('Owner profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= AVATAR =================
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primaryColor,
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
                      radius: 18,
                      backgroundColor: Colors.black54,
                      child:
                          const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _field(_fullNameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              _field(_emailController, 'Email', Icons.email, enabled: false),
              const SizedBox(height: 16),
              _field(_phoneController, 'Phone', Icons.phone),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
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

  // ================= FIELD =================
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
    );
  }
}
