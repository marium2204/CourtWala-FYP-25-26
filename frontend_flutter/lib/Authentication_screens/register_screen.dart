import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'google_role_screen.dart';
import '../constants/api_constants.dart';
import '../services/token_service.dart';
import '../services/google_auth_service.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String selectedRole = 'PLAYER';
  File? profileImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  // ================= NORMAL REGISTER =================
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register');
      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'firstName': firstNameCtrl.text.trim(),
        'lastName': lastNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'role': selectedRole,
      });

      if (usernameCtrl.text.trim().isNotEmpty) {
        request.fields['username'] = usernameCtrl.text.trim();
      }
      if (phoneCtrl.text.trim().isNotEmpty) {
        request.fields['phone'] = phoneCtrl.text.trim();
      }

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            profileImage!.path,
          ),
        );
      }

      final res = await request.send();
      final body = jsonDecode(await res.stream.bytesToString());

      if (res.statusCode == 201 && body['success'] == true) {
        await TokenService.saveToken(body['data']['token']);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Registration failed')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= GOOGLE SIGN UP =================
  Future<void> _continueWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final idToken = await GoogleAuthService.signInWithGoogle();
      if (idToken == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoogleRoleScreen(idToken: idToken),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E5D7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF65AAC2)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Image.asset('assets/Court.png', height: size.height * 0.14),
                const SizedBox(height: 12),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65AAC2),
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.camera_alt)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: firstNameCtrl,
                  decoration: inputDecoration('First Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: lastNameCtrl,
                  decoration: inputDecoration('Last Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: usernameCtrl,
                  decoration: inputDecoration('Username (optional)'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: phoneCtrl,
                  decoration: inputDecoration('Phone (optional)'),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: inputDecoration('Role'),
                  items: const [
                    DropdownMenuItem(value: 'PLAYER', child: Text('Player')),
                    DropdownMenuItem(
                        value: 'COURT_OWNER', child: Text('Court Owner')),
                  ],
                  onChanged: (v) => setState(() => selectedRole = v!),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: emailCtrl,
                  decoration: inputDecoration('Email *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: inputDecoration('Password *'),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65AAC2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF65AAC2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔽 COURT OWNER INFO (KEPT)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: ExpansionTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.orange),
                    title: const Text(
                      'Court Owner verification required',
                      style: TextStyle(fontSize: 11),
                    ),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: const [
                      Text(
                        'If you are registering as a Court Owner, please email the following documents along with your registered username and email to:',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '📧 courtwala@gmail.com',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• CNIC (Front & Back)'),
                      Text(
                          '• Property ownership papers OR rent/lease agreement'),
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

                const SizedBox(height: 24),

                // 🔵 GOOGLE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _continueWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.google,
                          size: 18,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
