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

  // Derived
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

  // ====================== UI ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white)),
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
                _tile('Pending Courts', pendingCourtApprovals,
                    Icons.pending_actions),
                _tile('Pending Owners', pendingOwnerApprovals,
                    Icons.person_search),

                const SizedBox(height: 24),

                // ===== NEW SECTION =====
                _sectionTitle('Platform Insights'),

                _progressStat(
                  'Court Approval Progress',
                  totalCourts - pendingCourtApprovals,
                  totalCourts,
                  Colors.green,
                  labelSuffix: 'approved',
                ),

                _progressStat(
                  'Owners Awaiting Approval',
                  totalOwners - pendingOwnerApprovals,
                  totalOwners,
                  Colors.blue,
                  labelSuffix: 'pending',
                ),

                // _progressStat(
                //   'Players in System',
                //   totalPlayers,
                //   totalUsers,
                //   Colors.orange,
                //   labelSuffix: 'players',
                // ),

                // _progressStat(
                //   'Court Owners in System',
                //   totalOwners,
                //   totalUsers,
                //   Colors.purple,
                //   labelSuffix: 'owners',
                // ),

                _infoStat(
                  'Average Bookings per Court',
                  totalCourts == 0
                      ? '0'
                      : (totalBookings / totalCourts).toStringAsFixed(1),
                ),
              ],
            ),
    );
  }

  // ====================== HELPERS ======================

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _progressStat(
    String title,
    int value,
    int total,
    Color color, {
    String? labelSuffix,
  }) {
    final percent = total == 0 ? 0.0 : value / total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${value}/${total})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent,
              color: color,
              backgroundColor: color.withOpacity(0.2),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${(percent * 100).toStringAsFixed(1)}% ${labelSuffix ?? ''}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoStat(String title, String value) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(title),
          trailing: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );

  Widget _tile(String title, int value, IconData icon) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(title),
          trailing: Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );

  Drawer _drawer() => Drawer(
        child: ListView(
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
            const Divider(),
            _nav('Announcements', Icons.announcement,
                () => _push(AnnouncementsScreen(adminToken: adminToken!))),
            _nav('Reports', Icons.report,
                () => _push(ReportsScreen(adminToken: adminToken!))),
            _nav('Tournaments', Icons.emoji_events,
                () => _push(ManageTournamentsScreen(adminToken: adminToken!))),
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
