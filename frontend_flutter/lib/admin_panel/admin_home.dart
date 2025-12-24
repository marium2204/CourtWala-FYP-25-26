import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

import '../authentication_screens/splash_screen.dart';

import 'manage_courts.dart';

import 'manage_users.dart';
import 'announcements.dart';
import 'reports.dart';
import 'tournaments.dart';
import 'manage_owners.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? adminToken;
  bool isLoading = true;

  int totalUsers = 0;
  int totalCourts = 0;
  int totalBookings = 0;
  int pendingCourtApprovals = 0;
  int pendingOwnerApprovals = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await TokenService.getToken();

    if (!mounted) return;

    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
      return;
    }

    adminToken = token;
    await _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final res = await ApiService.get(
        '/admin/dashboard',
        adminToken!,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];

        setState(() {
          totalUsers = (data['totalPlayers'] ?? 0) + (data['totalOwners'] ?? 0);
          totalCourts = data['totalCourts'] ?? 0;
          totalBookings = data['totalBookings'] ?? 0;
          pendingCourtApprovals = data['pendingCourts'] ?? 0;
          pendingOwnerApprovals = data['pendingOwners'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Dashboard error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: _drawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _tile('Total Users', totalUsers, Icons.people),
                _tile('Total Courts', totalCourts, Icons.sports_tennis),
                _tile('Total Bookings', totalBookings, Icons.book_online),
                _tile(
                  'Pending Courts',
                  pendingCourtApprovals,
                  Icons.pending_actions,
                ),
                _tile(
                  'Pending Owners',
                  pendingOwnerApprovals,
                  Icons.person_search,
                ),
              ],
            ),
    );
  }

  Drawer _drawer() => Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text('admin@courtwala.com'),
              decoration: BoxDecoration(color: AppColors.primaryColor),
            ),

            // ===== USER & COURT MANAGEMENT =====
            _nav(
              'Manage Users',
              Icons.people,
              () => _push(ManageUsersScreen(adminToken: adminToken!)),
            ),
            _nav(
              'Manage Courts',
              Icons.sports_tennis,
              () => _push(ManageCourtsScreen(adminToken: adminToken!)),
            ),
            _nav(
              'Manage Court Owners',
              Icons.sports_tennis,
              () => _push(ManageOwnersScreen(adminToken: adminToken!)),
            ),
            const Divider(),

            // ===== COMMUNICATION & MODERATION =====
            _nav(
              'Announcements',
              Icons.announcement,
              () => _push(AnnouncementsScreen(adminToken: adminToken!)),
            ),
            _nav(
              'Reports',
              Icons.report,
              () => _push(ReportsScreen(adminToken: adminToken!)),
            ),
            _nav(
              'Tournaments',
              Icons.emoji_events,
              () => _push(ManageTournamentsScreen(adminToken: adminToken!)),
            ),

            const Divider(),

            // ===== LOGOUT =====
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                await TokenService.clear();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      );

  ListTile _nav(String title, IconData icon, VoidCallback onTap) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      );

  void _push(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _tile(String title, int value, IconData icon) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(title),
          trailing: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
}
