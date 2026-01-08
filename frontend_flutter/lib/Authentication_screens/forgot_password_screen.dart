import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';
import '../constants/api_constants.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> sendResetRequest() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailCtrl.text.trim()}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      final decoded = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Request failed')),
      );
    }
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              /// =========================
              /// Image
              /// =========================
              Image.asset(
                'assets/forgot.png',
                height: size.height * 0.18,
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
                  children: [
                    Text(
                      'Forgot Password',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your email address and we’ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        hintText: 'Email address',
                        hintStyle: AppTextStyles.subtitle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : sendResetRequest,
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
                                'SEND RESET EMAIL',
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
}
