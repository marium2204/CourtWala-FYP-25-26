import 'package:flutter/material.dart';
import '../Authentication_screens/welcome_screen.dart';
import '../services/token_service.dart';

class OwnerPendingScreen extends StatelessWidget {
  const OwnerPendingScreen({super.key});

  Future<void> _goToWelcome(BuildContext context) async {
    // Optional but recommended: clear auth token
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
      backgroundColor: const Color(0xFFE7E5D7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 64,
                color: Color(0xFF65AAC2),
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Under Review',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF65AAC2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Court Owner account is currently under review.\n\n'
                'Please submit the required documents and wait for admin approval. '
                'You will be notified once your account is activated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: ExpansionTile(
                  leading: const Icon(Icons.info_outline, color: Colors.orange),
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
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _goToWelcome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65AAC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
