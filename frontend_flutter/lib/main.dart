import 'package:courtwala/Owner_Panel/owner_home.dart';
import 'package:courtwala/Player_Panel/ai_chatbot_screen.dart';
import 'package:courtwala/admin_panel/admin_home.dart';
import 'package:courtwala/player_Panel/player_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication_screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CourtWalaApp());
}

class CourtWalaApp extends StatelessWidget {
  const CourtWalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CourtWala',
      home: AdminHomeScreen(), // ✅ SINGLE ENTRY POINT
    );
  }
}
