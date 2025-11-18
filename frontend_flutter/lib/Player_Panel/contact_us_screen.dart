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
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Intro text
                          Text(
                            "We’d love to hear from you! Send us your queries or feedback.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: "Full Name",
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _emailController,
                                  label: "Email Address",
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _messageController,
                                  label: "Message",
                                  icon: Icons.message_outlined,
                                  maxLines: 5,
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Message sent successfully!')),
                                        );
                                        _nameController.clear();
                                        _emailController.clear();
                                        _messageController.clear();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 60, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                      shadowColor:
                                          Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Text(
                                      "Send Message",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Spacer to push footer down
                          const Spacer(),

                          // Footer
                          Center(
                            child: Text(
                              "© 2025 CourtWala. All rights reserved.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    if (maxLines == 1) {
      // single-line text field
      return TextFormField(
        controller: controller,
        validator: (value) =>
            value!.isEmpty ? 'Please enter your $label' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      );
    } else {
      // multi-line text field (Message)
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your $label' : null,
                  decoration: InputDecoration(
                    hintText: label,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
