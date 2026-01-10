import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/auth_gate.dart';

import 'manage_courts.dart';
import 'manage_users.dart';
import 'manage_bookings.dart';
import 'manage_owners.dart';
import 'announcements.dart';

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

  int totalPlayers = 0;
  int totalOwners = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await TokenService.getToken();
    if (!mounted) return;

    if (token == null) {
      _goToSplash();
      return;
    }

    adminToken = token;
    await _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final res = await ApiService.get('/admin/dashboard', adminToken!);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];

        setState(() {
          totalPlayers = data['totalPlayers'] ?? 0;
          totalOwners = data['totalOwners'] ?? 0;

          totalUsers = totalPlayers + totalOwners;
          totalCourts = data['totalCourts'] ?? 0;
          totalBookings = data['totalBookings'] ?? 0;
          pendingCourtApprovals = data['pendingCourts'] ?? 0;
          pendingOwnerApprovals = data['pendingOwners'] ?? 0;

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard error: $e');
      setState(() => isLoading = false);
    }
  }

  /* ================= LOGOUT ================= */

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await TokenService.clear();
    _goToSplash();
  }

  void _goToSplash() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ hamburger icon
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: _drawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: AppTextStyles.heading),
                  const SizedBox(height: 16),

                  /// =========================
                  /// STATS GRID (ALL RESTORED)
                  /// =========================
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _statCard('Total Users', totalUsers, Icons.people),
                      _statCard(
                          'Total Courts', totalCourts, Icons.sports_tennis),
                      _statCard(
                          'Total Bookings', totalBookings, Icons.book_online),
                      _statCard('Pending Courts', pendingCourtApprovals,
                          Icons.pending_actions),
                      _statCard('Pending Owners', pendingOwnerApprovals,
                          Icons.person_search),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Platform Insights', style: AppTextStyles.heading),
                  const SizedBox(height: 12),

                  _progressStat(
                    'Court Approval Progress',
                    totalCourts - pendingCourtApprovals,
                    totalCourts,
                    Colors.green,
                    labelSuffix: 'approved',
                  ),
                  _progressStat(
                    'Owner Approval Progress',
                    totalOwners - pendingOwnerApprovals,
                    totalOwners,
                    Colors.blue,
                    labelSuffix: 'approved',
                  ),
                  _infoStat(
                    'Average Bookings per Court',
                    totalCourts == 0
                        ? '0'
                        : (totalBookings / totalCourts).toStringAsFixed(1),
                  ),
                ],
              ),
            ),
    );
  }

  /* ================= HELPERS ================= */

  Widget _statCard(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const Spacer(),
          Text(value.toString(), style: AppTextStyles.title),
          Text(title, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  Widget _progressStat(
    String title,
    int value,
    int total,
    Color color, {
    String? labelSuffix,
  }) {
    final percent = total == 0 ? 0.0 : value / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text(
            '${(percent * 100).toStringAsFixed(1)}% ${labelSuffix ?? ''}',
            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _infoStat(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Drawer _drawer() => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text('admin@courtwala.com'),
              decoration: BoxDecoration(color: AppColors.primaryColor),
            ),
            _nav('Manage Users', Icons.people,
                () => _push(ManageUsersScreen(adminToken: adminToken!))),
            _nav('Manage Courts', Icons.sports_tennis,
                () => _push(ManageCourtsScreen(adminToken: adminToken!))),
            _nav('Manage Court Owners', Icons.person,
                () => _push(ManageOwnersScreen(adminToken: adminToken!))),
            _nav('Manage Bookings', Icons.book_online,
                () => _push(ManageBookingsScreen(adminToken: adminToken!))),
            const Divider(),
            _nav('Announcements', Icons.announcement,
                () => _push(AnnouncementsScreen(adminToken: adminToken!))),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      );

  ListTile _nav(String title, IconData icon, VoidCallback onTap) =>
      ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);

  void _push(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
