import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../Admin_Panel/announcements.dart';
import '../Admin_Panel/manage_bookings.dart';
import '../Admin_Panel/manage_courts.dart';
import '../Admin_Panel/manage_owners.dart';
import '../Admin_Panel/manage_players.dart';
import '../Admin_Panel/reports.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // sample stats (replace with real backend data)
  int totalPlayers = 1240;
  int totalOwners = 84;
  int totalCourts = 312;
  int totalBookings = 2150;

  // sample bookings trend (last 7 days)
  final List<int> bookingsTrend = [20, 30, 25, 40, 35, 45, 50];

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
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
            title:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admin logged out (placeholder)')),
              );
            },
          ),
        ]),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        titleSpacing: -1,
        title: Text(
          _selectedIndex == 0
              ? 'Admin Dashboard'
              : _selectedIndex == 1
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
              icon: Icon(Icons.report_gmailerrorred), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ===== Top Stats =====
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Players', totalPlayers.toString(),
                    AppColors.primaryColor)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Owners', totalOwners.toString(), Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Courts', totalCourts.toString(), AppColors.accentColor)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Bookings', totalBookings.toString(), Colors.green)),
          ],
        ),
        const SizedBox(height: 20),

        // ===== Bookings Trend =====
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Bookings Trend (7 days)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue)),
                Text('$totalBookings total',
                    style: const TextStyle(color: Colors.grey)),
              ]),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                double maxHeight = 70;
                double spacing = 4;
                final maxBooking =
                    bookingsTrend.reduce((a, b) => a > b ? a : b);
                return SizedBox(
                  height: maxHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bookingsTrend.map((v) {
                      final heightFactor =
                          maxBooking == 0 ? 0.0 : v / maxBooking;
                      return Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: spacing / 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (maxHeight - 20) * heightFactor + 8,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                child: Text(v.toString(),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ]),
          ),
        ),

        const SizedBox(height: 18),

        // ===== Quick Actions =====
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.headingBlue)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 1.25,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _quickActionTile(Icons.person_search, 'Manage Owners', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageOwnersScreen()));
            }),
            _quickActionTile(Icons.people, 'Manage Players', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManagePlayersScreen()));
            }),
            _quickActionTile(Icons.sports_tennis, 'Manage Courts', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageCourtsScreen()));
            }),
            _quickActionTile(Icons.calendar_today, 'Manage Bookings', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageBookingsScreen()));
            }),
            _quickActionTile(Icons.report, 'Reports', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()));
            }),
            _quickActionTile(Icons.campaign, 'Announcements', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen()));
            }),
          ],
        ),

        const SizedBox(height: 18),

        // ===== Recent Activity =====
        const Text('Recent Activity',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.headingBlue)),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Column(children: [
            ListTile(
              leading:
                  const Icon(Icons.person_add, color: AppColors.primaryColor),
              title: const Text('New owner registered'),
              subtitle: const Text('Owner: Ali Ahmed • 2 hours ago'),
              trailing: TextButton(onPressed: () {}, child: const Text('View')),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.book_online, color: Colors.green),
              title: const Text('Booking canceled'),
              subtitle:
                  const Text('Court: Elite Badminton Arena • 5 hours ago'),
              trailing: TextButton(onPressed: () {}, child: const Text('View')),
            ),
          ]),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(10),
            child: Icon(
              title == 'Players'
                  ? Icons.person
                  : title == 'Owners'
                      ? Icons.business
                      : title == 'Courts'
                          ? Icons.sports_tennis
                          : Icons.book_online,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingBlue)),
          ])
        ]),
      ),
    );
  }

  Widget _quickActionTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.headingBlue),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Manage',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.visible,
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
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Hard-coded credentials'),
              subtitle:
                  const Text('Email/password are stored in code (placeholder)'),
            ),
          ),
        ]),
      ),
    );
  }
}
