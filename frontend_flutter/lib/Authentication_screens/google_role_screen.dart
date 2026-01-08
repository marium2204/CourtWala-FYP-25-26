import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/token_service.dart';

import '../admin_panel/admin_home.dart';
import '../Owner_Panel/owner_home.dart';
import '../Player_Panel/player_home.dart';
import '../Authentication_screens/owner_pending_screen.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// =========================
              /// Top Image
              /// =========================
              Image.asset(
                'assets/role selection.png', // ✅ change if needed
                height: size.height * 0.22,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              /// =========================
              /// Card
              /// =========================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose your role',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 24),
                    _roleTile(
                      value: 'PLAYER',
                      title: 'Player',
                      subtitle: 'Book courts and join games',
                    ),
                    const SizedBox(height: 12),
                    _roleTile(
                      value: 'COURT_OWNER',
                      title: 'Court Owner',
                      subtitle: 'Manage courts and bookings',
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'CONTINUE',
                                style: AppTextStyles.button,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTile({
    required String value,
    required String title,
    required String subtitle,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedRole,
      onChanged: (v) => setState(() => selectedRole = v!),
      activeColor: AppColors.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.subtitle.copyWith(
          fontSize: 13,
        ),
      ),
    );
  }
}
