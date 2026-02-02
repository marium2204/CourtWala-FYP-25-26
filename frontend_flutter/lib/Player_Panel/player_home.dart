import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/auth_gate.dart';
import '../constants/api_constants.dart';

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
          courts = data['courts'] ?? [];
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
      drawer: _drawer(),
      appBar: _appBar(),
      body: _selectedIndex == 1
          ? const MatchmakingScreen()
          : _selectedIndex == 2
              ? const ChallengesScreen()
              : _selectedIndex == 3
                  ? const CommunityScreen()
                  : _courtsContent(),
      bottomNavigationBar: _bottomNav(),
    );
  }

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
      itemBuilder: (_, i) => CourtCard(court: courts[i]),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          "It's Game Time!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      );

  BottomNavigationBar _bottomNav() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: "Courts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Matchmaking"),
          BottomNavigationBarItem(
              icon: Icon(Icons.whatshot), label: "Challenges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Community"),
        ],
      );

  Drawer _drawer() => Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
              decoration: const BoxDecoration(color: AppColors.primaryColor),
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
                        color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text('Play. Book. Compete.',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      );
}

// ================= COURT CARD =================

class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;
  const CourtCard({super.key, required this.court});

  String? get _firstImage {
    final images = (court['images'] as List?)?.cast<String>() ?? [];
    if (images.isEmpty) return null;
    return images.first; // Cloudinary URL
  }

  @override
  Widget build(BuildContext context) {
    final String name = court['name'] ?? 'Unnamed Court';
    final String location = court['location'] ?? '';
    final String price = court['pricePerHour']?.toString() ?? '--';
    final String courtId = court['id'];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourtDetailScreen(courtId: courtId)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: _firstImage != null
                  ? Image.network(
                      _firstImage!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text("PKR $price / hr",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor)),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 110,
        height: 110,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 40),
      );
}
