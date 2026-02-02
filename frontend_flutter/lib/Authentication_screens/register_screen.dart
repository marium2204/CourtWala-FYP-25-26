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
import '../services/image_upload_service.dart'; // ✅ ADDED
import 'login_screen.dart';
import 'auth_gate.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

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
  String? profileImageUrl; // ✅ ADDED
  bool isLoading = false;

  bool _obscurePassword = true;

  final ImagePicker _picker = ImagePicker();

  // ================= IMAGE PICK (UNCHANGED UI) =================
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^03\d{9}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Phone must start with 03\nand contain 11 digits';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) {
      return 'Password must be at\nleast 6 characters';
    }
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)');
    if (!regex.hasMatch(value)) {
      return 'Password must contain uppercase,\nlowercase and number';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ================= REGISTER (IMAGE FIX ONLY) =================
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔽 CLOUDINARY IMAGE UPLOAD (ADDED)
      if (profileImage != null) {
        profileImageUrl = await ImageUploadService.uploadToCloudinary(
          profileImage!,
          folder: "courtwala/profiles",
        );
      }

      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstNameCtrl.text.trim(),
          'lastName': lastNameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
          'role': selectedRole,
          if (usernameCtrl.text.trim().isNotEmpty)
            'username': usernameCtrl.text.trim(),
          if (phoneCtrl.text.trim().isNotEmpty) 'phone': phoneCtrl.text.trim(),
          if (profileImageUrl != null)
            'profilePicture': profileImageUrl, // ✅ URL SENT
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 201 && body['success'] == true) {
        await TokenService.saveToken(body['data']['token']);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
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

  // ================= GOOGLE (UNCHANGED) =================
  Future<void> _continueWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final idToken = await GoogleAuthService.signInWithGoogle();
      if (idToken == null) return;

      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        final token = body['data']['token'];
        await TokenService.saveToken(token);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already exists. Please LOGIN'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
        return;
      }

      if (res.statusCode == 404) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GoogleRoleScreen(idToken: idToken),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration inputDecoration(String hint) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text('CREATE ACCOUNT', style: AppTextStyles.heading),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.borderColor,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? Icon(Icons.camera_alt, color: AppColors.primaryColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildCard([
                  _field(firstNameCtrl, 'First Name *', true),
                  _field(lastNameCtrl, 'Last Name *', true),
                  _field(usernameCtrl, 'Username (optional)', false),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: phoneCtrl,
                      decoration: inputDecoration('Phone (optional)'),
                      validator: phoneValidator,
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: emailCtrl,
                      decoration: inputDecoration('Email *'),
                      validator: emailValidator,
                    ),
                  ),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: _obscurePassword,
                    validator: passwordValidator,
                    decoration: inputDecoration('Password *').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('REGISTER', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Already have an account? Login',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _courtOwnerInfo(),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _continueWithGoogle,
                  icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                  label: const Text('Continue with Google'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String h, bool req) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: inputDecoration(h),
        validator: req ? (v) => v!.isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _courtOwnerInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentColor),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: AppColors.accentColor),
        title: const Text('Court Owner verification required'),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: const [
          Text('Email documents to: courtwala@gmail.com'),
          SizedBox(height: 8),
          Text('• CNIC (Front & Back)'),
          Text('• Property papers / rent agreement'),
          Text('• Authorization letter'),
          Text('• Court images (3–5)'),
          SizedBox(height: 8),
          Text('Approval usually takes up to 24 hours.',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
