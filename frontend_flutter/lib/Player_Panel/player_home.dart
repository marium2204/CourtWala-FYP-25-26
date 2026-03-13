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
import 'about_us_screen.dart';
import 'my_bookings_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> _allCourts = [];
  List<Map<String, dynamic>> _filteredCourts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourts();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        final List list = data['courts'] ?? [];

        setState(() {
          _allCourts = List<Map<String, dynamic>>.from(list);
          _filteredCourts = _allCourts;
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

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Logged out successfully'),
      duration: Duration(seconds: 3),
    ),
  );

  if (!mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const AuthGate()),
    (_) => false,
  );
}

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() => _filteredCourts = _allCourts);
      return;
    }

    setState(() {
      _filteredCourts = _allCourts.where((court) {
        final name = (court['name'] ?? '').toString().toLowerCase();
        final city = (court['city'] ?? '').toString().toLowerCase();

        final sportsText = (court['sports'] as List?)
                ?.map((s) => s['name'].toString().toLowerCase())
                .join(' ') ??
            '';

        return name.contains(query) ||
            city.contains(query) ||
            sportsText.contains(query);
      }).toList();
    });
  }

  // ================= BANNER CAROUSEL =================

  Widget _homeBannerCarousel() {
    final PageController controller = PageController();
    int currentIndex = 0;

    final banners = [
      _BannerData(
        title: "Book Your Favourite Court",
        subtitle: "Nearby courts • Instant booking",
        image: "assets/900W-90-flood-light-illuminate-tennis-court.jpg",
        onTap: () => setState(() => _selectedIndex = 0),
      ),
      _BannerData(
        title: "Challenge a Player",
        subtitle: "Find opponents • Compete • Win",
        image:
            "assets/black-gradient-football-field-background-inst-design-template-45f0c6eea75ea829f5e7bee1347353fc_69e643f6-94f5-4963-a199-c6198e51ae93_screen.png",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChallengesScreen()),
        ),
      ),
      _BannerData(
        title: "Chat with CourtWala AI ",
        subtitle: "Ask • Plan • Get instant help",
        image: "assets/tt-1724319499860.webp",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
    ];

    return StatefulBuilder(
      builder: (context, setStateSB) {
        return Column(
          children: [
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: controller,
                itemCount: banners.length,
                onPageChanged: (i) => setStateSB(() => currentIndex = i),
                itemBuilder: (_, i) {
                  final b = banners[i];
                  return GestureDetector(
                    onTap: b.onTap,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(b.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.15),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == i ? 14 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == i
                        ? AppColors.primaryColor
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================

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

    if (_allCourts.isEmpty) {
      return const Center(child: Text('No courts available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _homeBannerCarousel(),
        const SizedBox(height: 18),
        // 🔍 SEARCH BAR (UI ONLY)
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search courts by name, city or sport...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        if (_filteredCourts.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'No courts found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

        ..._filteredCourts.map((c) => CourtCard(court: c)),
      ],
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
                  Text('CourtWala',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
    return images.first;
  }

  @override
  Widget build(BuildContext context) {
    final String name = court['name'] ?? 'Unnamed Court';
    final String address = court['address'] ?? '';
    final String city = court['city'] ?? '';
    final String price = court['pricePerHour']?.toString() ?? '--';
    final String courtId = court['id'];

    final List sports = (court['sports'] as List?) ?? [];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourtDetailScreen(courtId: courtId),
        ),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: _firstImage != null
                  ? Image.network(
                      _firstImage!,
                      width: 110,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            // DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COURT NAME
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

                    // 📍 ADDRESS + CITY
                    if (address.isNotEmpty || city.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [address, city]
                                  .where((e) => e.isNotEmpty)
                                  .join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 6),

                    // 🏷 SPORTS CHIPS
                    if (sports.isNotEmpty)
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: sports.map<Widget>((s) {
                          final sportName = s['name']?.toString() ?? '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              sportName,
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

                    // PRICE
                    Text(
                      " PKR $price / hr",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
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

// ================= HELPERS =================

class _BannerData {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });
}
