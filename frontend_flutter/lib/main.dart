import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Authentication_screens/auth_gate.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CourtWalaApp());
}

class CourtWalaApp extends StatelessWidget {
  const CourtWalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CourtWala',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: const AuthGate(),
    );
  }
}
