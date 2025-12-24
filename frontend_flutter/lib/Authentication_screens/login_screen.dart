import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/token_service.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

// ✅ PANEL IMPORTS (REQUIRED)
import '../admin_panel/admin_home.dart';
import '../Owner_Panel/owner_home.dart';
import '../Player_Panel/player_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailOrUsernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  Future<void> _loginUser() async {
    if (emailOrUsernameCtrl.text.trim().isEmpty ||
        passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrUsername': emailOrUsernameCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['token'];
        final user = decoded['data']['user'];

        await TokenService.saveToken(token);

        // 🚫 Handle non-active users
        if (user['status'] != 'ACTIVE') {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account status: ${user['status']}')),
          );
          return;
        }

        // 🎯 Role-based navigation (NO Splash)
        Widget nextScreen;

        switch (user['role']) {
          case 'ADMIN':
            nextScreen = const AdminHomeScreen();
            break;
          case 'COURT_OWNER':
            nextScreen = const CourtOwnerHomeScreen();
            break;
          default:
            nextScreen = const PlayerHomeScreen();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
          (_) => false,
        );
      } else {
        final errorMessage = decoded['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E5D7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF65AAC2)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Image.asset('assets/Court.png', height: size.height * 0.16),
              const SizedBox(height: 10),

              const Text(
                'Login to CourtWala',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF65AAC2),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailOrUsernameCtrl,
                decoration: _inputDecoration('Email or Username'),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: passwordCtrl,
                obscureText: !showPassword,
                decoration: _inputDecoration(
                  'Password',
                  suffix: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65AAC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF65AAC2)),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don’t have an account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Create one',
                      style: TextStyle(
                        color: Color(0xFF65AAC2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 🔽 Expandable Court Owner Info
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: ExpansionTile(
                  leading: const Icon(Icons.info_outline, color: Colors.orange),
                  title: const Text(
                    'Court Owner approval pending?',
                    style: TextStyle(fontSize: 12),
                  ),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: const [
                    Text(
                      'If you registered as a Court Owner, please email the following documents along with your registered username and email to:',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '📧 courtwala@gmail.com',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• CNIC (Front & Back)'),
                    Text('• Property ownership papers OR rent/lease agreement'),
                    Text(
                        '• Authorization letter (if manager is registering on owner’s behalf)'),
                    Text('• Court proof pictures (3–5 clear photos)'),
                    Text('• Court address (Google Maps pin is recommended)'),
                    SizedBox(height: 8),
                    Text(
                      'Approval usually takes up to 24 hours.',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
}
