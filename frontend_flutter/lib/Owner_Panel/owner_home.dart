import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'courtdetail_screen.dart';
import 'add_court_screen.dart';
import '../Player_Panel/ai_chatbot_screen.dart';
import '../Player_Panel/notifications_screen.dart';
import '../Player_Panel/about_us_screen.dart';
import '../Player_Panel/contact_us_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_profile_screen.dart';
import '../Player_Panel/community_screen.dart';
import 'edit_court_screen.dart';

class CourtOwnerHomeScreen extends StatefulWidget {
  const CourtOwnerHomeScreen({super.key});

  @override
  State<CourtOwnerHomeScreen> createState() => _CourtOwnerHomeScreenState();
}

class _CourtOwnerHomeScreenState extends State<CourtOwnerHomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> courts = [
    {
      'name': 'Elite Badminton Arena',
      'sport': 'Badminton',
      'rating': 4.8,
      'image': 'assets/badmintonCourt.jpeg',
      'bookings': 25,
    },
    {
      'name': 'Champions Cricket Ground',
      'sport': 'Cricket',
      'rating': 4.5,
      'image': 'assets/logo.png',
      'bookings': 12,
    },
    {
      'name': 'Padel Court Central',
      'sport': 'Padel',
      'rating': 4.7,
      'image': 'assets/Court.png',
      'bookings': 18,
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Title logic like Player Home
    String appBarTitle;
    switch (_selectedIndex) {
      case 1:
        appBarTitle = "Bookings";
        break;
      case 2:
        appBarTitle = "Community";
        break;
      case 3:
        appBarTitle = "Profile";
        break;
      default:
        appBarTitle = "Let the games begin!";
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Court Owner'),
              accountEmail: Text('owner@email.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/player_avatar.png'),
              ),
              decoration: BoxDecoration(color: AppColors.primaryColor),
            ),

            // ---------------- HOME ----------------
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // ---------------- ABOUT US ----------------
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),

            // ---------------- CONTACT US ----------------
            ListTile(
              leading: const Icon(Icons.contact_mail_outlined),
              title: const Text("Contact Us"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // -------------------- SAME APPBAR AS PLAYER HOME --------------------
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        titleSpacing: -1,
        title: Text(
          appBarTitle,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),

      // -------------------- BODY --------------------
      body: _selectedIndex == 0 ? _homeContent() : _otherScreens(),

      // -------------------- SAME BOTTOM NAV STYLE --------------------
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
              icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Community"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  // -------------------- COURT OWNER HOME CONTENT --------------------
  Widget _homeContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ADD COURT BUTTON
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditCourtScreen()));
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                const Text("Add Court", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: courts.length,
              itemBuilder: (context, index) {
                return _courtCard(courts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _courtCard(Map<String, dynamic> court) {
    return Container(
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
      child: Column(
        children: [
          Row(
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
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(court['rating'].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("🏸 ${court['sport']}",
                            style:
                                const TextStyle(color: AppColors.accentColor)),
                        Text("📅 Bookings: ${court['bookings']}",
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ]),
                ),
              ),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              children: [
                // Edit Court Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCourtScreen(court: court),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    label: const Text(
                      "Edit Court Details",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // View Court Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourtDetails(
                            courtName: court['name'],
                            location: 'Owner Location',
                            sport: court['sport'],
                            price: 'PKR 2000/hr',
                            image: court['image'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye, size: 18),
                    label: const Text("View Court Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side:
                          BorderSide(color: AppColors.primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  // -------------------- PLACEHOLDER OTHER SCREENS --------------------
  Widget _otherScreens() {
    switch (_selectedIndex) {
      case 1:
        return const CourtOwnerBookingsScreen();
      case 2:
        return const CommunityScreen();
      case 3:
        return const CourtOwnerProfileScreen();
      default:
        return const SizedBox();
    }
  }
}
