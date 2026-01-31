import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'welcome_screen.dart';
// later you can add:
// import 'player_home.dart';
// import 'court_owner_home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _routeUser();
  }

  Future<void> _routeUser() async {
    final token = await TokenService.getToken();
    final userId = await TokenService.getUserId();
    final role = await TokenService.getRole();
    ;
    // ✅ DEBUG PRINTS
    print('JWT token: $token');
    print('User ID from token: $userId');
    print('User role from token: $role');

    if (!mounted) return;

    if (token == null) {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } else {
      // Logged in
      // TODO: decode token and route by role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Invisible screen
    return const Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
