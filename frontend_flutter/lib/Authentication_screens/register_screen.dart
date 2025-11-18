import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final List<String> roles = ['Player', 'Court Owner'];
  String selectedRole = 'Player';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _submitted = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF65AAC2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFADBA5E), width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _validateForm({bool fromButton = false}) {
    if (fromButton) _submitted = true;

    setState(() {
      _usernameError =
          _usernameController.text.isEmpty ? 'Username is required' : null;

      const emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
      final emailRegExp = RegExp(emailPattern);
      _emailError = _emailController.text.isEmpty
          ? 'Email is required'
          : (!emailRegExp.hasMatch(_emailController.text)
              ? 'Enter a valid email'
              : null);

      const passPattern = r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
      final passRegExp = RegExp(passPattern);
      _passwordError = _passwordController.text.isEmpty
          ? 'Password is required'
          : (!passRegExp.hasMatch(_passwordController.text)
              ? 'Password must be 8+ chars, include uppercase, number & special char'
              : null);

      _confirmPasswordError = _confirmPasswordController.text.isEmpty
          ? 'Please confirm your password'
          : (_confirmPasswordController.text != _passwordController.text
              ? 'Passwords do not match'
              : null);
    });
  }

  bool _isFormValid() {
    return selectedRole.isNotEmpty &&
        _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google signup successful!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google signup failed: $e')),
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                const SizedBox(height: 10),

                Image.asset(
                  'assets/Court.png',
                  height: size.height * 0.16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 6),

                const Text(
                  'Sign Up to Get Started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65AAC2),
                  ),
                ),
                const SizedBox(height: 15),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select Role'),
                  dropdownColor: Colors.white,
                  value: selectedRole,
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'Player');
                    if (_submitted) _validateForm(fromButton: false);
                  },
                  items: roles
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Username
                TextField(
                  controller: _usernameController,
                  onChanged: (_) {
                    if (_submitted) _validateForm(fromButton: false);
                  },
                  decoration: _inputDecoration('Username'),
                ),
                if (_submitted && _usernameError != null)
                  _errorText(_usernameError!),
                const SizedBox(height: 10),

                // Email
                TextField(
                  controller: _emailController,
                  onChanged: (_) {
                    if (_submitted) _validateForm(fromButton: false);
                  },
                  decoration: _inputDecoration('Email'),
                ),
                if (_submitted && _emailError != null) _errorText(_emailError!),
                const SizedBox(height: 10),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  onChanged: (_) {
                    if (_submitted) _validateForm(fromButton: false);
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
                if (_submitted && _passwordError != null)
                  _errorText(_passwordError!),
                const SizedBox(height: 10),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  onChanged: (_) {
                    if (_submitted) _validateForm(fromButton: false);
                  },
                  decoration: _inputDecoration(
                    'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                if (_submitted && _confirmPasswordError != null)
                  _errorText(_confirmPasswordError!),
                const SizedBox(height: 15),

                // Continue Button
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
                      _validateForm(fromButton: true);

                      if (!_isFormValid()) return;

                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration successful!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(e.message ?? 'Registration failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Google Sign-Up
                const Text(
                  'or signup with Google instead:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65AAC2),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _signUpWithGoogle,
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
                    'Sign up with Google',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF65AAC2),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
