import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/api_constants.dart';
import '../services/token_service.dart';
import '../services/google_auth_service.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

import '../admin_panel/admin_home.dart';
import '../Owner_Panel/owner_home.dart';
import '../Player_Panel/player_home.dart';
import '../Authentication_screens/owner_pending_screen.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailOrUsernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  /* ================= EMAIL LOGIN ================= */
  Future<void> _loginUser() async {
    if (emailOrUsernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrUsername': emailOrUsernameCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
        }),
      );

      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['token'];
        final user = decoded['data']['user'];

        await TokenService.saveToken(token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful"),
            duration: Duration(seconds: 3),
          ),
        );

        if (!mounted) return;
        _navigateByRoleAndStatus(user['role'], user['status']);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['message'] ?? 'Login failed')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /* ================= GOOGLE LOGIN ================= */
  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final firebaseIdToken = await GoogleAuthService.signInWithGoogle();
      if (firebaseIdToken == null) {
        setState(() => isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': firebaseIdToken}),
      );

      final decoded = jsonDecode(res.body);

      if (res.statusCode != 200 || decoded['success'] != true) {
        throw decoded['message'] ?? 'Google login failed';
      }

      final token = decoded['data']['token'];
      final user = decoded['data']['user'];

      await TokenService.saveToken(token);
      ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("Google login successful"),
    duration: Duration(seconds: 3),
  ),
);

      if (!mounted) return;
      _navigateByRoleAndStatus(user['role'], user['status']);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login failed')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /* ================= NAVIGATION ================= */
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

  InputDecoration _dec(String hint, {Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      hintText: hint,
      hintStyle: AppTextStyles.subtitle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('LOGIN TO COURTWALA', style: AppTextStyles.heading),
              const SizedBox(height: 24),
              _buildCard(
                Column(
                  children: [
                    TextField(
                      controller: emailOrUsernameCtrl,
                      decoration: _dec('Email'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: !showPassword,
                      decoration: _dec(
                        'Password',
                        suffix: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('LOGIN', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                    color: Color.fromARGB(255, 8, 74, 128),
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Color.fromARGB(255, 8, 74, 128),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: Text(
                  'Dont have an account? SignUp',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}
