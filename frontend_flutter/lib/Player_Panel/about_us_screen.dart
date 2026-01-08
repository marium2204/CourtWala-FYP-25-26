import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/gradient_background.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                const Text(
                  "About CourtWala",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Connecting players, courts, and communities — one match at a time.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ================= MISSION =================
                _infoCard(
                  icon: Icons.flag_outlined,
                  title: "Our Mission",
                  content:
                      "CourtWala is dedicated to making sports accessible for everyone. We provide a seamless platform for booking courts, finding matches, and engaging with sports communities.",
                ),

                const SizedBox(height: 24),

                // ================= TEAM =================
                _infoCard(
                  icon: Icons.people_outline,
                  title: "Our Team",
                  content:
                      "We are a passionate group of sports enthusiasts and tech innovators, working together to bring convenience and connectivity to the world of sports.",
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

  // ================= INFO CARD =================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
