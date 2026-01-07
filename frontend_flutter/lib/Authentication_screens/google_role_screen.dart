import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/token_service.dart';

import '../admin_panel/admin_home.dart';
import '../Owner_Panel/owner_home.dart';
import '../Player_Panel/player_home.dart';
import '../Authentication_screens/owner_pending_screen.dart';

class GoogleRoleScreen extends StatefulWidget {
  final String idToken;

  const GoogleRoleScreen({super.key, required this.idToken});

  @override
  State<GoogleRoleScreen> createState() => _GoogleRoleScreenState();
}

class _GoogleRoleScreenState extends State<GoogleRoleScreen> {
  String selectedRole = 'PLAYER';
  bool isLoading = false;

  Future<void> _continue() async {
    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/google/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': widget.idToken,
          'role': selectedRole,
        }),
      );

      final body = jsonDecode(res.body);

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          body['success'] == true) {
        final token = body['data']['token'];
        final user = body['data']['user'];

        final String role = user['role'];
        final String status = user['status'];

        await TokenService.saveToken(token);

        if (!mounted) return;
        _navigateByRoleAndStatus(role, status);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _navigateByRoleAndStatus(String role, String status) {
    Widget next;

    if (role == 'COURT_OWNER' && status == 'PENDING_APPROVAL') {
      next = const OwnerPendingScreen();
    } else if (role == 'ADMIN') {
      next = const AdminHomeScreen();
    } else if (role == 'COURT_OWNER') {
      next = const CourtOwnerHomeScreen();
    } else {
      next = const PlayerHomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => next),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E5D7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF65AAC2),
                ),
              ),
              const SizedBox(height: 30),
              RadioListTile<String>(
                value: 'PLAYER',
                groupValue: selectedRole,
                onChanged: (v) => setState(() => selectedRole = v!),
                title: const Text('Player'),
              ),
              RadioListTile<String>(
                value: 'COURT_OWNER',
                groupValue: selectedRole,
                onChanged: (v) => setState(() => selectedRole = v!),
                title: const Text('Court Owner'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65AAC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
