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

  /// ✅ SPORTS & SKILLS
  List<Map<String, String>> sports = [];

  final List<String> availableSports = [
    'BADMINTON',
    'FOOTBALL',
    'PADEL',
    'CRICKET',
  ];

  final List<String> skills = [
    'BEGINNER',
    'INTERMEDIATE',
    'ADVANCED',
  ];

  bool _savingProfile = false;
  bool _savingSports = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();

    _firstNameCtrl =
        TextEditingController(text: widget.profile['firstName'] ?? '');
    _lastNameCtrl =
        TextEditingController(text: widget.profile['lastName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.profile['phone'] ?? '');

    /// ✅ SAFE MAPPING FROM BACKEND → UI
    sports = (widget.profile['sports'] as List? ?? [])
        .map((e) => {
              'sport': e['sport'].toString(),
              'skillLevel': e['skillLevel'].toString(),
            })
        .toList();
  }

  // ================= SAVE PROFILE INFO =================
  Future<void> _saveProfileInfo() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _savingProfile = true);
    final token = await TokenService.getToken();

    await ApiService.put('/player/profile', token!, {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    });

    setState(() => _savingProfile = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  // ================= SAVE SPORTS =================
  Future<void> _saveSports() async {
    if (sports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one sport'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _savingSports = true);
    final token = await TokenService.getToken();

    final res = await ApiService.put(
      '/player/profile/sports',
      token!,
      {'sports': sports},
    );

    final body = jsonDecode(res.body);

    setState(() => _savingSports = false);

    if (body['success'] == true) {
      Navigator.pop(context, true); // 🔑 refresh ProfileScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'] ?? 'Failed to save sports'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= CHANGE PASSWORD =================
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _changingPassword = true);
    final token = await TokenService.getToken();

    await ApiService.post('/player/profile/change-password', token!, {
      'currentPassword': _currentPasswordCtrl.text,
      'newPassword': _newPasswordCtrl.text,
    });

    setState(() => _changingPassword = false);

    _currentPasswordCtrl.clear();
    _newPasswordCtrl.clear();
    _confirmPasswordCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed')),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileSection(),
            const SizedBox(height: 24),
            _sportsSection(),
            const SizedBox(height: 24),
            _passwordSection(),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE SECTION =================
  Widget _profileSection() => _card(
        'Profile Information',
        Form(
          key: _profileFormKey,
          child: Column(
            children: [
              _field(_firstNameCtrl, 'First Name'),
              _field(_lastNameCtrl, 'Last Name'),
              _field(_phoneCtrl, 'Phone'),
              const SizedBox(height: 12),
              _primaryButton(
                'Save Profile',
                _savingProfile,
                _saveProfileInfo,
              ),
            ],
          ),
        ),
      );

  // ================= SPORTS SECTION =================
  Widget _sportsSection() => _card(
        'Sports & Skills',
        Column(
          children: [
            ...sports.asMap().entries.map((e) => _sportEditor(e.key)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  sports.add({
                    'sport': availableSports.first,
                    'skillLevel': skills.first,
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Sport'),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              'Save Sports',
              _savingSports,
              _saveSports,
            ),
          ],
        ),
      );

  // ================= PASSWORD SECTION =================
  Widget _passwordSection() => _card(
        'Change Password',
        Form(
          key: _passwordFormKey,
          child: Column(
            children: [
              _field(_currentPasswordCtrl, 'Current Password', obscure: true),
              _field(_newPasswordCtrl, 'New Password', obscure: true),
              _field(_confirmPasswordCtrl, 'Confirm Password', obscure: true),
              const SizedBox(height: 12),
              _primaryButton(
                'Change Password',
                _changingPassword,
                _changePassword,
              ),
            ],
          ),
        ),
      );

  // ================= SPORT EDITOR =================
  Widget _sportEditor(int i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: sports[i]['sport'],
                decoration: const InputDecoration(labelText: 'Sport'),
                items: availableSports
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    sports[i]['sport'] = v!;
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: sports[i]['skillLevel'],
                decoration: const InputDecoration(labelText: 'Skill Level'),
                items: skills
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    sports[i]['skillLevel'] = v!;
                  });
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      sports.removeAt(i);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );

  // ================= UI HELPERS =================
  Widget _card(String title, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _primaryButton(
    String text,
    bool loading,
    VoidCallback onPressed,
  ) =>
      SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      );
}
