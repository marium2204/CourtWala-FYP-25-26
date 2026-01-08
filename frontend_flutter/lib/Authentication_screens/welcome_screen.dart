import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// =========================
                /// Logo Section
                /// =========================
                SizedBox(height: size.height * 0.001),
                Image.asset(
                  'assets/welcome.png',
                  height: size.height * 0.30,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: size.height * 0.03),

                /// =========================
                /// Text Container (Visual Anchor)
                /// =========================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
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
                        'WELCOME',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Login or signup to continue and start booking your courts',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.07),

                /// =========================
                /// Signup Button (Primary CTA)
                /// =========================
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'CREATE ACCOUNT',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.025),

                /// =========================
                /// Login Button (Secondary CTA)
                /// =========================
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.065,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.35),
                        width: 1.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      'LOGIN',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
