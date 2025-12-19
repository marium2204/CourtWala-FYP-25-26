import 'package:flutter/material.dart';

class ManageBookingsScreen extends StatelessWidget {
  final String adminToken;

  const ManageBookingsScreen({super.key, required this.adminToken});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Admin has read-only access to bookings',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
