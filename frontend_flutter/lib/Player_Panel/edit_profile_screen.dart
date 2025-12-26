// lib/Player_Panel/edit_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _savingProfile = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl =
        TextEditingController(text: widget.profile['firstName'] ?? '');
    _lastNameCtrl =
        TextEditingController(text: widget.profile['lastName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.profile['phone'] ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _savingProfile = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final res = await ApiService.put(
        '/player/profile', // ✅ CORRECT
        token,
        {
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        Navigator.pop(context, true);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _savingProfile = false);
    }
  }

  // ================= CHANGE PASSWORD =================
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _changingPassword = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final res = await ApiService.post(
        '/player/profile/change-password', // ✅ CORRECT
        token,
        {
          'currentPassword': _currentPasswordCtrl.text,
          'newPassword': _newPasswordCtrl.text,
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _changingPassword = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile Information',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _profileFormKey,
              child: Column(
                children: [
                  _field(_firstNameCtrl, 'First Name'),
                  _field(_lastNameCtrl, 'Last Name'),
                  _field(_phoneCtrl, 'Phone'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _savingProfile ? null : _updateProfile,
                    child: _savingProfile
                        ? const CircularProgressIndicator()
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Change Password',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _field(_currentPasswordCtrl, 'Current Password',
                      obscure: true),
                  _field(
                    _newPasswordCtrl,
                    'New Password',
                    obscure: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  _field(
                    _confirmPasswordCtrl,
                    'Confirm Password',
                    obscure: true,
                    validator: (v) =>
                        v != _newPasswordCtrl.text ? 'Mismatch' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _changingPassword ? null : _changePassword,
                    child: _changingPassword
                        ? const CircularProgressIndicator()
                        : const Text('Change Password'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
