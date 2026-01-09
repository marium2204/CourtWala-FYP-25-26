import 'package:flutter/material.dart';

import '../Authentication_screens/welcome_screen.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

class OwnerPendingScreen extends StatelessWidget {
  const OwnerPendingScreen({super.key});

  Future<void> _goToWelcome(BuildContext context) async {
    await TokenService.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        size: 40,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Account Under Review',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Court Owner account is currently under review.\n\n'
                      'Please submit the required documents and wait for admin approval. '
                      'You will be notified once your account is activated.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _verificationInfo(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _goToWelcome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'OK',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _verificationInfo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.info_outline,
          color: AppColors.primaryColor,
        ),
        title: Text(
          'Court Owner verification required',
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Text(
            'Please email the following documents along with your registered username and email to:',
            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '📧 courtwala@gmail.com',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text('• CNIC (Front & Back)'),
          const Text('• Property ownership OR rent/lease agreement'),
          const Text(
              '• Authorization letter (if registering on owner’s behalf)'),
          const Text('• Court images (3–5 clear photos)'),
          const Text('• Court address (Google Maps pin preferred)'),
          const SizedBox(height: 10),
          Text(
            'Approval usually takes up to 24 hours.',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
