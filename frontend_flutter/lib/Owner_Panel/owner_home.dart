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
      backgroundColor: const Color(0xFFF6F8FA),
      drawer: _drawer(),
      appBar: _appBar(title),
      body: _selectedIndex == 0 ? _homeContent() : _otherScreens(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Future<void> _confirmDeleteCourt(Map<String, dynamic> court) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Court'),
        content: const Text(
          'This will permanently delete this court.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteCourt(court['id']);
    }
  }

  Future<void> _deleteCourt(String courtId) async {
    try {
      final res = await ApiService.delete(
        '/owner/courts/$courtId',
        token!,
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Court deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchCourts(); // refresh list
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete court'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _homeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditCourtScreen()),
                );
                _fetchCourts();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Court",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: courts.isEmpty
                ? const Center(
                    child: Text(
                      'No courts added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
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
    final List<Map<String, dynamic>> sports =
        (court['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),

              // ===== NAME + SPORTS =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court['name'] ?? 'Unnamed Court',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ✅ CLEAN SPORTS ROW
                    if (sports.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: sports.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // ===== STATUS =====
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  court['status'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // ===== ACTIONS =====
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          _outlinedButton(
            'Delete Court',
            Icons.delete_outline,
            () => _confirmDeleteCourt(court),
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

  BottomNavigationBar _bottomNav() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
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
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      );

  Drawer _drawer() => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
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
            // ListTile(
            //   leading: const Icon(Icons.contact_mail_outlined),
            //   title: const Text("Contact Us"),
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            //   ),
            // ),
          ],
        ),
      );

  Widget _actionButton(String text, IconData icon, VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: Colors.white),
          label: Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  Widget _outlinedButton(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) =>
      SizedBox(
        width: double.infinity,
        height: 45,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
