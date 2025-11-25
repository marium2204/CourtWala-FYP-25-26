import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../Admin_Panel/announcements.dart';
import '../Admin_Panel/manage_bookings.dart';
import '../Admin_Panel/manage_courts.dart';
import '../Admin_Panel/manage_owners.dart';
import '../Admin_Panel/manage_players.dart';
import '../Admin_Panel/reports.dart';
import '../admin_panel/tournaments.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // Temporary sample values — replace with real backend values later
  int totalUsers = 2000;
  int totalCourts = 312;
  int totalBookings = 2150;
  int pendingCourtApprovals = 14;
  int pendingOwnerApprovals = 6;
  int activeReports = 22;

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text('admin@courtwala.app'),
              decoration: BoxDecoration(color: AppColors.primaryColor),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.accentColor,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text('Manage Owners'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageOwnersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Players'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManagePlayersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_tennis),
              title: const Text('Manage Courts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageCourtsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Manage Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageBookingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Admin logged out (placeholder)')),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        titleSpacing: -1,
        title: Text(
          _selectedIndex == 0
              ? 'Admin Dashboard'
              : _selectedIndex == 1
                  ? 'Announcements'
                  : _selectedIndex == 2
                      ? 'Reports'
                      : 'Profile',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
              ? const AnnouncementsScreen()
              : _selectedIndex == 2
                  ? const ReportsScreen()
                  : const AdminProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.announcement), label: 'Announcements'),
          BottomNavigationBarItem(
              icon: Icon(Icons.report_gmailerrorred), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOTAL PLAYERS
          _dashboardTile(
            title: 'Total Players',
            value: totalUsers.toString(),
            icon: Icons.people,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePlayersScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // TOTAL COURT OWNERS
          _dashboardTile(
            title: 'Total Court Owners',
            value: pendingOwnerApprovals.toString(),
            icon: Icons.person_search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOwnersScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // TOTAL COURTS
          _dashboardTile(
            title: 'Total Courts',
            value: totalCourts.toString(),
            icon: Icons.sports_tennis,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCourtsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // TOTAL BOOKINGS
          _dashboardTile(
            title: 'Total Bookings',
            value: totalBookings.toString(),
            icon: Icons.book_online,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBookingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // ACTIVE REPORTS
          _dashboardTile(
            title: 'Active Reports',
            value: activeReports.toString(),
            icon: Icons.report,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // ANNOUNCEMENTS CARD
          _dashboardTile(
            title: 'Announcements',
            value: '5', // Replace with real count later
            icon: Icons.announcement,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // TOURNAMENTS CARD
          _dashboardTile(
            title: 'Tournaments',
            value: '3', // Replace with real tournament count later
            icon: Icons.emoji_events,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageTournamentsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _dashboardTile({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 👉 Manage Button on the right
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Manage",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.accentColor,
              child: Icon(Icons.admin_panel_settings, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Admin',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingBlue)),
          const SizedBox(height: 6),
          const Text('admin@courtwala.app',
              style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}
