import 'dart:convert';
import 'package:courtwala/player_Panel/about_us_screen.dart';
import 'package:courtwala/player_Panel/contact_us_screen.dart';
import 'package:courtwala/player_Panel/tournaments_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/splash_screen.dart';

import 'court_detail_screen.dart';
import 'matchmaking_screen.dart';
import 'community_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'ai_chatbot_screen.dart';
import 'my_bookings_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  List courts = [];

  final List<String> carouselImages = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.webp',
  ];

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
        MaterialPageRoute(builder: (_) => const SplashScreen()),
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
      } else {
        throw Exception(res.body);
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
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,

      // ================= DRAWER =================
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.sports, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'CourtWala',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
        title: const Text(
          "It's Game Time!",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            ),
          ),
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
        type: BottomNavigationBarType.fixed, // ✅ REQUIRED
        backgroundColor: Colors.white, // ✅ REQUIRED
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600, // ✅ FIX
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

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(height: 180, autoPlay: true),
          items: carouselImages.map((img) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  Image.asset(img, fit: BoxFit.cover, width: double.infinity),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              return CourtCard(court: courts[index]);
            },
          ),
        ),
      ],
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.sports_tennis,
                size: 40, color: AppColors.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court['name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(court['location'] ?? ''),
                  Text("PKR ${court['price']} / hr",
                      style: const TextStyle(color: AppColors.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
