// lib/Player_Panel/contact_us_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/gradient_background.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= INTRO =================
                Text(
                  "We’d love to hear from you!",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Send us your questions, feedback, or suggestions and we’ll get back to you.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ================= FORM CARD =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 18),
                        _buildField(
                          controller: _emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 18),
                        _buildField(
                          controller: _messageController,
                          label: "Message",
                          icon: Icons.message_outlined,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Message sent successfully!'),
                                  ),
                                );
                                _nameController.clear();
                                _emailController.clear();
                                _messageController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Send Message",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ================= FOOTER =================
                Center(
                  child: Text(
                    "© 2025 CourtWala. All rights reserved.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
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

  // ================= FIELD =================
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter your $label' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
