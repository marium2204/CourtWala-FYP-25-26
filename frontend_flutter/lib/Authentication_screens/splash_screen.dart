import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/token_service.dart';

import 'welcome_screen.dart';
import '../admin_panel/admin_home.dart';
import '../Owner_Panel/owner_home.dart';
import '../Player_Panel/player_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _checkSession);
  }

  Future<void> _checkSession() async {
    try {
      // 🔐 Get stored JWT
      final token = await TokenService.getToken();

      if (token == null) {
        _goToWelcome();
        return;
      }

      // 🔍 Validate token & get user info
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        await TokenService.clear();
        _goToWelcome();
        return;
      }

      final decoded = jsonDecode(response.body);
      final user = decoded['data'];

      // 🚫 Block inactive users
      if (user['status'] != 'ACTIVE') {
        await TokenService.clear();
        _goToWelcome();
        return;
      }

      // 🎯 Route by role
      Widget nextScreen;

      switch (user['role']) {
        case 'ADMIN':
          nextScreen = const AdminHomeScreen();
          break;
        case 'COURT_OWNER':
          nextScreen = const CourtOwnerHomeScreen();
          break;
        default:
          nextScreen = const PlayerHomeScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      // Any error → safe fallback
      await TokenService.clear();
      _goToWelcome();
    }
  }

  void _goToWelcome() {
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
