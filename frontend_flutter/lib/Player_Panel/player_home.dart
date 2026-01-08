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
import 'contact_us_screen.dart';
import 'tournaments_screen.dart';

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
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactUsScreen(),
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
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            ),
          ),
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
                  ? const TournamentsScreen()
                  : _selectedIndex == 4
                      ? const ProfileScreen()
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
              icon: Icon(Icons.emoji_events), label: "Tournaments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourtDetailScreen(courtId: court['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.sports_tennis,
                size: 34,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court['name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    court['location'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "PKR ${court['price']} / hr",
                    style: const TextStyle(
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
