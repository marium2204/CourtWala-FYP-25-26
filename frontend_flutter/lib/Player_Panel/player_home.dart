import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/auth_gate.dart';

import 'court_detail_screen.dart';
import 'matchmaking_screen.dart';
import 'community_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'ai_chatbot_screen.dart';
import 'my_bookings_screen.dart';
import 'about_us_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  List courts = [];

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  // ================= FETCH COURTS =================
  Future<void> _fetchCourts() async {
    final token = await TokenService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
      return;
    }

    try {
      final res = await ApiService.get('/courts', token);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        setState(() {
          courts = data['courts'];
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

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await TokenService.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),

      // ================= DRAWER =================
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.sports_tennis, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'CourtWala',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Play. Book. Compete.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyBookingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail_outlined),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          "It's Game Time!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: _selectedIndex == 1
          ? const MatchmakingScreen()
          : _selectedIndex == 2
              ? const ChallengesScreen()
              : _selectedIndex == 3
                  ? const CommunityScreen()
                  : _courtsContent(),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: "Courts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Matchmaking"),
          BottomNavigationBarItem(
              icon: Icon(Icons.whatshot), label: "Challenges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Community"),
        ],
      ),
    );
  }

  // ================= COURTS UI =================
  Widget _courtsContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courts.isEmpty) {
      return const Center(child: Text('No courts available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courts.length,
      itemBuilder: (context, index) {
        return CourtCard(court: courts[index]);
      },
    );
  }
}

// ================= COURT CARD =================
class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;
  const CourtCard({super.key, required this.court});

  IconData _sportIcon(String sport) {
    switch (sport.toUpperCase()) {
      case 'BADMINTON':
        return Icons.sports_tennis;
      case 'CRICKET':
        return Icons.sports_cricket;
      case 'FOOTBALL':
        return Icons.sports_soccer;
      case 'PADEL':
        return Icons.sports_tennis;
      case 'TENNIS':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String courtId = court['id']?.toString() ?? '';
    final String name = court['name']?.toString() ?? 'Unnamed Court';
    final String location = court['location']?.toString() ?? '';
    final String price = court['price']?.toString() ?? '--';

    // ✅ NORMALIZE SPORTS (OBJECTS → NAMES)
    final List<String> sports = (court['sports'] is List)
        ? (court['sports'] as List)
            .map((s) => s is Map ? s['name']?.toString() ?? '' : s.toString())
            .where((s) => s.isNotEmpty)
            .toList()
        : [];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (courtId.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourtDetailScreen(courtId: courtId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _sportIcon(sports.isNotEmpty ? sports.first : ''),
                size: 28,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(width: 12),

            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ✅ CLEAN SPORTS CHIPS
                  if (sports.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: sports.map((sport) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sport,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    "PKR $price / hr",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
