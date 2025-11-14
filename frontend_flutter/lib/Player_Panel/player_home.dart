import 'package:courtwala/Player_Panel/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:courtwala/Player_Panel/my_bookings_screen.dart';
import 'package:courtwala/Player_Panel/about_us_screen.dart';
import 'package:courtwala/Player_Panel/contact_us_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'ai_chatbot_screen.dart';
import 'matchmaking_screen.dart';
import 'challenges_screen.dart';
import 'community_screen.dart';
import '../theme/colors.dart';
import 'court_detail_screen.dart';
import "notifications_screen.dart";

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> carouselImages = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.webp',
  ];

  final List<Map<String, dynamic>> courts = [
    {
      'name': 'Elite Badminton Arena',
      'availability': 'Available Now',
      'location': 'Gulshan, Karachi',
      'price': 'PKR 2000/hr',
      'sport': 'Badminton',
      'rating': 4.8,
      'image': 'assets/badmintonCourt.jpeg',
    },
    {
      'name': 'Champions Cricket Ground',
      'availability': 'Available Tomorrow',
      'location': 'DHA Phase 6, Karachi',
      'price': 'PKR 5000/hr',
      'sport': 'Cricket',
      'rating': 4.5,
      'image': 'assets/logo.png',
    },
    {
      'name': 'Padel Court Central',
      'availability': 'Available Now',
      'location': 'North Nazimabad, Karachi',
      'price': 'PKR 2500/hr',
      'sport': 'Padel',
      'rating': 4.7,
      'image': 'assets/Court.png',
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _drawerTile(
      BuildContext context, IconData icon, String title, Widget? navigateTo) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // close drawer
        if (navigateTo != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => navigateTo));
        } else {
          setState(() => _selectedIndex = 0); // stay on home
        }
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Resize with keyboard
      backgroundColor: AppColors.backgroundBeige, // ✅ Beige background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filter Courts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  // Use Column for dropdowns to avoid horizontal overflow
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Sport',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['Football', 'Badminton', 'Cricket', 'Padel']
                            .map((sport) => DropdownMenuItem(
                                  value: sport,
                                  child: Text(sport),
                                ))
                            .toList(),
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Availability',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['Available Now', 'Available Tomorrow']
                            .map((val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ))
                            .toList(),
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Price Range (PKR)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle;
    switch (_selectedIndex) {
      case 1:
        appBarTitle = "Find Opponents";
        break;
      case 2:
        appBarTitle = "Community";
        break;
      case 3:
        appBarTitle = "Challenges";
        break;
      case 4:
        appBarTitle = "Profile";
        break;
      default:
        appBarTitle = "It's Game Time!";
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Player Name'),
              accountEmail: const Text('player@email.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/player_avatar.png'),
              ),
              decoration: const BoxDecoration(color: AppColors.primaryColor),
            ),
            _drawerTile(context, Icons.home, 'Home', null),
            _drawerTile(context, Icons.calendar_today, 'My Bookings',
                const MyBookingsScreen()),
            _drawerTile(
                context, Icons.info_outline, 'About Us', const AboutUsScreen()),
            _drawerTile(context, Icons.contact_mail_outlined, 'Contact Us',
                const ContactUsScreen()),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        titleSpacing: -1,
        title: Text(appBarTitle,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()));
            },
          ),
        ],
      ),
      body: _selectedIndex == 1
          ? const MatchmakingScreen()
          : _selectedIndex == 2
              ? const CommunityScreen()
              : _selectedIndex == 3
                  ? const ChallengesScreen()
                  : _selectedIndex == 4
                      ? const ProfileScreen()
                      : _homeContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis), label: "Courts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Matchmaking"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Community"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), label: "Challenges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return Column(
      children: [
        // Carousel
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              autoPlayInterval: const Duration(seconds: 4),
            ),
            items: carouselImages.map((imgPath) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(imgPath,
                        fit: BoxFit.cover, width: double.infinity),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        // Search + Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    ),
                    hintText: "Search for courts...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _showFilterSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                icon: const Icon(Icons.filter_list, color: Colors.white),
                label: const Text("Filters",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        // Court Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: courts.length,
            itemBuilder: (context, index) {
              final court = courts[index];
              return CourtCard(court: court);
            },
          ),
        ),
      ],
    );
  }
}

class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;
  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    Color availabilityColor =
        court['availability'].contains("Now") ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourtDetailScreen(
              courtName: court['name'],
              location: court['location'],
              sport: court['sport'],
              price: court['price'],
              image: court['image'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
              child: Image.asset(court['image'],
                  width: 120, height: 100, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(court['name'],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.headingBlue)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(court['rating'].toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("🏷️ ${court['price']}",
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600)),
                      Text("📍 ${court['location']}",
                          style: const TextStyle(color: Colors.grey)),
                      Text("🏸 ${court['sport']}",
                          style: const TextStyle(color: AppColors.accentColor)),
                      Text("🕒 ${court['availability']}",
                          style: TextStyle(
                              color: availabilityColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(double.infinity, 30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white), // <-- changed to white
                        ),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
