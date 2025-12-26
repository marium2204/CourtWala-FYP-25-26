// lib/Player_Panel/profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';
import 'edit_profile_screen.dart';
import '../authentication_screens/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;

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

      final res = await ApiService.get(
        '/player/profile', // ✅ CORRECT
        token,
      );

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await TokenService.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
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
    final username = _profile!['username'] ?? '—';
    final skillLevel = _profile!['skillLevel'] ?? '—';
    final role = _profile!['role'] ?? '—';

    final List sports = _profile!['preferredSports'] is List
        ? _profile!['preferredSports']
        : [];
    final sportsText = sports.isNotEmpty ? sports.join(', ') : '—';

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= HEADER =================
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accentColor,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Text(
              fullName.isEmpty ? '—' : fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.headingBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            _infoTile('Username', username),
            _infoTile('Role', role),
            _infoTile('Skill Level', skillLevel),
            _infoTile('Preferred Sports', sportsText),

            const SizedBox(height: 24),

            // ================= ACTIONS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
