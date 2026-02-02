// lib/Player_Panel/profile_screen.dart
import 'dart:convert';
import 'dart:io'; // ✅ ADDED
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';
import 'edit_profile_screen.dart';
import '../authentication_screens/auth_gate.dart';
import 'package:image_picker/image_picker.dart';

// ✅ ADDED
import '../services/image_upload_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;

  // ✅ ADDED (DO NOT REMOVE OLD VARIABLES)
  File? _newProfileImage;
  bool _savingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ================= FETCH PROFILE =================
  Future<void> _fetchProfile() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        _logout();
        return;
      }

      final res = await ApiService.get('/player/profile', token);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _profile = body['data'];
          _loading = false;
        });
      } else {
        throw Exception(body['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
      setState(() => _loading = false);
    }
  }

  // ================= PICK IMAGE (NO UPLOAD) =================
  Future<void> _pickProfileImage() async {
    final picked = await ImageUploadService.pickImage(ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _newProfileImage = picked;
    });
  }

  // ================= SAVE IMAGE (UPLOAD + API UPDATE) =================
  Future<void> _saveProfileImage() async {
    if (_newProfileImage == null) return;

    setState(() => _savingImage = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      // 🔼 Upload to Cloudinary
      final imageUrl = await ImageUploadService.uploadToCloudinary(
        _newProfileImage!,
        folder: 'courtwala/profiles',
      );

      // 🔁 Update backend with URL
      final res = await ApiService.put(
        '/player/profile',
        token,
        {'profilePicture': imageUrl},
      );

      if (res.statusCode == 200) {
        _newProfileImage = null;
        _fetchProfile();
      } else {
        throw Exception('Image update failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await TokenService.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load profile')),
      );
    }

    final fullName =
        '${_profile!['firstName'] ?? ''} ${_profile!['lastName'] ?? ''}'.trim();
    final email = _profile!['email'] ?? '—';
    final role = _profile!['role'] ?? '—';

    final List sports = _profile!['sports'] is List ? _profile!['sports'] : [];

    final bool profileIncomplete = sports.isEmpty;

    final sportsText = sports.isEmpty
        ? '—'
        : sports.map((s) => '${s['sport']} (${s['skillLevel']})').join(', ');

    // ✅ IMAGE PRIORITY: new image → saved image → fallback
    final String? profilePictureUrl = _profile!['profilePicture'] as String?;

    final ImageProvider? profileImageProvider = _newProfileImage != null
        ? FileImage(_newProfileImage!) as ImageProvider
        : (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
            ? NetworkImage(profilePictureUrl) as ImageProvider
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= PROFILE INCOMPLETE NOTICE =================
            if (profileIncomplete)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please complete your profile. You don’t have any sports and skills entered which may help you get challenges from other players.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // ================= HEADER CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage, // ✅ CHANGED (NO AUTO UPLOAD)
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor:
                              AppColors.primaryColor.withOpacity(0.15),
                          backgroundImage: profileImageProvider,
                          child: profileImageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: AppColors.primaryColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primaryColor,
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ SAVE BUTTON (ONLY WHEN IMAGE CHANGED)
                  if (_newProfileImage != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _savingImage ? null : _saveProfileImage,
                        child: _savingImage
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Save Image'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Text(
                    fullName.isEmpty ? '—' : fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= INFO CARDS =================
            _infoCard('Role', role),
            _infoCard('Preferred Sports', sportsText),

            const SizedBox(height: 28),

            // ================= ACTIONS =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: _profile!),
                    ),
                  );

                  if (updated == true) {
                    _fetchProfile();
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                label: const Text(
                  'Logout',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
