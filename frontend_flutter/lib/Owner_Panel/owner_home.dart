import 'dart:convert';

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

import 'courtdetail_screen.dart';
import 'add_court_screen.dart';
import 'edit_court_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_profile_screen.dart';
import '../Player_Panel/ai_chatbot_screen.dart';
import '../Player_Panel/notifications_screen.dart';
import '../Player_Panel/about_us_screen.dart';
import '../Player_Panel/contact_us_screen.dart';
import '../Player_Panel/community_screen.dart';

class CourtOwnerHomeScreen extends StatefulWidget {
  const CourtOwnerHomeScreen({super.key});

  @override
  State<CourtOwnerHomeScreen> createState() => _CourtOwnerHomeScreenState();
}

class _CourtOwnerHomeScreenState extends State<CourtOwnerHomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> courts = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    token = await TokenService.getToken();
    if (token != null) {
      await _fetchCourts();
    }
  }

  Future<void> _fetchCourts() async {
    try {
      final res = await ApiService.get('/owner/courts', token!);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data']['courts'] as List;
        setState(() {
          courts = list.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch courts error: $e');
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_selectedIndex) {
      1 => "Bookings",
      2 => "Community",
      3 => "Profile",
      _ => "Let the games begin!",
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      drawer: _drawer(),
      appBar: _appBar(title),
      body: _selectedIndex == 0 ? _homeContent() : _otherScreens(),
      bottomNavigationBar: _bottomNav(), // ✅ FIXED
    );
  }

  Widget _homeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditCourtScreen()),
              );
              _fetchCourts();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                const Text("Add Court", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: courts.isEmpty
                ? const Center(child: Text('No courts added yet'))
                : ListView.builder(
                    itemCount: courts.length,
                    itemBuilder: (_, i) => _courtCard(courts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _courtCard(Map<String, dynamic> court) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.sports_tennis,
                size: 40, color: AppColors.primaryColor),
            title: Text(
              court['name'] ?? 'Unnamed Court',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              court['sportType'] ?? '',
              style: const TextStyle(color: AppColors.accentColor),
            ),
            trailing: Chip(
              label: Text(court['status'] ?? ''),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _actionButton(
                  'Edit Court',
                  Icons.edit,
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCourtScreen(court: court),
                      ),
                    );
                    _fetchCourts();
                  },
                ),
                const SizedBox(height: 8),
                _outlinedButton(
                  'View Court',
                  Icons.remove_red_eye,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourtDetails(court: court),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherScreens() {
    return switch (_selectedIndex) {
      1 => const CourtOwnerBookingsScreen(),
      2 => const CommunityScreen(),
      3 => const CourtOwnerProfileScreen(),
      _ => const SizedBox(),
    };
  }

  // ================= FIXED BOTTOM NAV =================
  BottomNavigationBar _bottomNav() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // ✅ REQUIRED
        backgroundColor: Colors.white, // ✅ REQUIRED
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600, // ✅ FIX
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: "Courts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      );

  AppBar _appBar(String title) => AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      );

  Drawer _drawer() => Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Court Owner'),
              accountEmail: Text('owner@email.com'),
              decoration: BoxDecoration(color: AppColors.primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail_outlined),
              title: const Text("Contact Us"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              ),
            ),
          ],
        ),
      );

  Widget _actionButton(String text, IconData icon, VoidCallback onTap) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          minimumSize: const Size(double.infinity, 45),
        ),
      );

  Widget _outlinedButton(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor),
          minimumSize: const Size(double.infinity, 45),
        ),
      );
}
