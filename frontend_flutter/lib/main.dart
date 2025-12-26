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
      home: SplashScreen(), 
    );
  }
}
