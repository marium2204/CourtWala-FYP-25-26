//import 'package:courtwala/Admin_Panel/admin_home.dart';
import 'package:courtwala/Authentication_screens/splash_screen.dart';
import 'package:courtwala/Owner_Panel/owner_home.dart';
import 'package:courtwala/admin_panel/admin_home.dart';
//import 'package:courtwala/Owner_Panel/owner_home.dart';
//import 'package:courtwala/Player_Panel/player_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:courtwala/Player_Panel/player_home.dart';
//import 'package:courtwala/Player_Panel/court_detail_screen.dart';
//import 'Authentication_screens/splash_screen.dart';

void main() async {
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
      home: CourtOwnerHomeScreen(),
    );
  }
}
