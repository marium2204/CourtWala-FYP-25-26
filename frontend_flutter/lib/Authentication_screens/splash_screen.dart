import 'dart:async';
import 'package:flutter/material.dart';

import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏳ Wait 5 seconds, then go to Welcome Screen
    Timer(const Duration(seconds: 5), _goToWelcome);
  }

  void _goToWelcome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E5D7),
      body: Center(
        child: Image.asset(
          'assets/Court.png',
          height: MediaQuery.of(context).size.height * 0.35,
        ),
      ),
    );
  }
}
