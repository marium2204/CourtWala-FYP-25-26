import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../Player_Panel/player_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _submitted = false;
  bool _showPassword = false;

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
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

  void _validatePassword({bool fromButton = true}) {
    if (fromButton) _submitted = true;

    setState(() {
      _passwordError =
          _passwordController.text.isEmpty ? 'Password is required' : null;
    });
  }

  bool _isFormValid() {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ]);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in aborted')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PlayerHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e')),
      );
    }
  }

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
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF65AAC2),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Logo
                Image.asset(
                  'assets/Court.png',
                  height: size.height * 0.16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),

                // Heading
                const Text(
                  'Login to CourtWala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF65AAC2),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                TextField(
                  controller: _emailController,
                  onChanged: (_) {
                    if (_submitted) _validateEmail(fromButton: false);
                  },
                  decoration: _inputDecoration('Email'),
                ),
                if (_emailError != null) _errorText(_emailError!),
                const SizedBox(height: 10),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  onChanged: (_) {
                    if (_submitted) _validatePassword(fromButton: false);
                  },
                  decoration: _inputDecoration(
                    'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),
                if (_passwordError != null) _errorText(_passwordError!),
                const SizedBox(height: 20),

                // Login Button
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
                      _validatePassword();

                      if (!_isFormValid()) return;

                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login successful!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerHomeScreen()),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Login failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Google Login at bottom
                const Text(
                  'or login with Google instead:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65AAC2),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFF65AAC2))),
                    elevation: 2,
                  ),
                  icon:
                      const Icon(Icons.g_mobiledata, color: Color(0xFF65AAC2)),
                  label: const Text(
                    'Login with Google',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),

                // Forgot Password
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
                    style: TextStyle(
                      color: Color(0xFF65AAC2),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account? ',
                      style: TextStyle(
                        color: Color(0xFF869A69),
                        fontSize: 15,
                      ),
                    ),
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
