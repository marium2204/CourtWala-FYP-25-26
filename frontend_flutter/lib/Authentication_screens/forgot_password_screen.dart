import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _submitted = false;

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _validateEmail({bool fromButton = true}) {
    if (fromButton) _submitted = true;

    const pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regExp = RegExp(pattern);

    setState(() {
      _emailError = _emailController.text.isEmpty
          ? 'Email is required'
          : (!regExp.hasMatch(_emailController.text)
              ? 'Enter a valid email'
              : null);
    });
  }

  bool _isFormValid() =>
      _emailError == null && _emailController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E5D7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Arrow
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF65AAC2),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Logo
                Image.asset(
                  'assets/Court.png',
                  height: size.height * 0.16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),

                // Heading
                const Text(
                  'Forgot Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65AAC2),
                  ),
                ),
                const SizedBox(height: 6),

                // Subheading
                const Text(
                  'Add your email address associated with your account to recover your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF869A69),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),

                // Email Field
                TextField(
                  controller: _emailController,
                  onChanged: (_) {
                    if (_submitted) _validateEmail(fromButton: false);
                  },
                  decoration: _inputDecoration('Enter your email'),
                ),
                if (_emailError != null) _errorText(_emailError!),
                const SizedBox(height: 25),

                // Send Reset Email Button
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFADBA5E), Color(0xFF869A69)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      _validateEmail();
                      if (!_isFormValid()) return;

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: _emailController.text.trim());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Reset email sent! Check your inbox.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(e.message ?? 'Failed to send reset email'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Send Reset Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF65AAC2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }
}
