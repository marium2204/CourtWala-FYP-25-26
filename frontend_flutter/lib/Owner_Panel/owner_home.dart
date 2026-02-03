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

  // ================= INIT =================
  Future<void> _init() async {
    token = await TokenService.getToken();

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    await _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.get('/owner/courts', token!);

      debugPrint('COURTS STATUS: ${res.statusCode}');
      debugPrint('COURTS BODY: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        List list = [];

        // ✅ SUPPORT MULTIPLE BACKEND SHAPES
        if (decoded is Map) {
          if (decoded['data'] is Map && decoded['data']['courts'] is List) {
            list = decoded['data']['courts'];
          } else if (decoded['courts'] is List) {
            list = decoded['courts'];
          } else if (decoded['data'] is List) {
            list = decoded['data'];
          }
        }

        setState(() {
          courts = list.cast<Map<String, dynamic>>();
        });
      } else {
        debugPrint('Fetch courts failed: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch courts error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= DELETE COURT =================
  Future<void> _deleteCourt(String courtId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Court'),
        content: const Text(
          'Are you sure you want to delete this court? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ApiService.delete(
      '/owner/courts/$courtId',
      token!,
    );

    if (res.statusCode == 200) {
      _fetchCourts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Court deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete court')),
      );
    }
  }
// ================= BANNER CAROUSEL =================

  Widget _homeBannerCarousel() {
    final PageController controller = PageController();
    int currentIndex = 0;

    final banners = [
      _BannerData(
        title: "List Your Courts",
        subtitle: "List courts • Get instant booking",
        image: "assets/900W-90-flood-light-illuminate-tennis-court.jpg",
        onTap: () => setState(() => _selectedIndex = 0),
      ),
      _BannerData(
        title: "Accept Bookings",
        subtitle: "Approve bookings • Let them Compete",
        image:
            "assets/black-gradient-football-field-background-inst-design-template-45f0c6eea75ea829f5e7bee1347353fc_69e643f6-94f5-4963-a199-c6198e51ae93_screen.png",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CourtOwnerBookingsScreen()),
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

  Widget _homeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _homeBannerCarousel(),
          const SizedBox(height: 20),

          // ✅ ALWAYS SHOW ADD BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditCourtScreen(),
                  ),
                );
                _fetchCourts();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Court",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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

          // ✅ EMPTY STATE INSIDE CONTENT (NOT FULL SCREEN)
          if (courts.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No courts added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: courts.length,
                itemBuilder: (_, i) => _courtCard(courts[i]),
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ================= COURT CARD =================
  Widget _courtCard(Map<String, dynamic> court) {
    final List images = court['images'] is List ? court['images'] : [];
    final String? imageUrl = images.isNotEmpty ? images.first.toString() : null;

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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(height: 12),

          // Name + Location
          Text(
            court['name'] ?? 'Unnamed Court',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${court['city'] ?? ''} • ${court['address'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ SPORTS TAGS
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ((court['sports'] as List?) ?? []).map<Widget>((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 📌 STATUS TAG
              if (court['status'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(court['status']).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    court['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(court['status']),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 10),

          Row(
            children: [
              _iconAction(
                icon: Icons.edit,
                color: AppColors.primaryColor,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCourtScreen(court: court),
                    ),
                  );
                  _fetchCourts();
                },
              ),
              const SizedBox(width: 12),
              _iconAction(
                icon: Icons.remove_red_eye,
                color: AppColors.primaryColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourtDetails(court: court),
                  ),
                ),
              ),
              const Spacer(),
              _iconAction(
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => _deleteCourt(court['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 40),
        ),
      );

  // ================= OTHER SCREENS =================
  Widget _otherScreens() {
    return switch (_selectedIndex) {
      1 => const CourtOwnerBookingsScreen(),
      2 => const CommunityScreen(),
      3 => const CourtOwnerProfileScreen(),
      _ => const SizedBox(),
    };
  }

  // ================= NAV / APPBAR / DRAWER =================
  BottomNavigationBar _bottomNav() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          label: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
  // ================= HELPERS =================
}

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

Widget _iconAction({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

Color _statusColor(String status) {
  switch (status) {
    case 'ACTIVE':
      return Colors.green;
    case 'PENDING':
    case 'PENDING_APPROVAL':
      return Colors.orange;
    case 'BLOCKED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
