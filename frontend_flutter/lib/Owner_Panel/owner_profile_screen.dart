import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/auth_gate.dart';
import 'owner_profile_edit.dart';

class CourtOwnerProfileScreen extends StatefulWidget {
  const CourtOwnerProfileScreen({super.key});

  @override
  State<CourtOwnerProfileScreen> createState() =>
      _CourtOwnerProfileScreenState();
}

class _CourtOwnerProfileScreenState extends State<CourtOwnerProfileScreen> {
  bool isLoading = true;

  Map<String, dynamic>? owner;
  Map<String, dynamic>? dashboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ================= LOAD PROFILE + DASHBOARD =================
  Future<void> _loadData() async {
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
      final profileRes = await ApiService.get('/owner/profile', token);
      if (profileRes.statusCode != 200) {
        throw Exception(profileRes.body);
      }

      final dashboardRes = await ApiService.get('/owner/dashboard', token);
      if (dashboardRes.statusCode != 200) {
        throw Exception(dashboardRes.body);
      }

      setState(() {
        owner = jsonDecode(profileRes.body)['data'];
        dashboard = jsonDecode(dashboardRes.body)['data'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Owner profile load error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (owner == null || dashboard == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load profile')),
      );
    }

    // ================= SAFE DATA =================
    final firstName = owner!['firstName'] ?? '';
    final lastName = owner!['lastName'] ?? '';
    final name = ('$firstName $lastName').trim().isNotEmpty
        ? '$firstName $lastName'
        : 'Court Owner';

    final email = owner!['email'] ?? '';
    final phone = owner!['phone'] ?? '-';
    final status = owner!['status'] ?? 'UNKNOWN';

    final joinedDate = owner!['createdAt'] != null
        ? DateTime.parse(owner!['createdAt']).toLocal().toString().split(' ')[0]
        : '-';

    final totalCourts = dashboard!['totalCourts'] ?? 0;
    final totalBookings = dashboard!['totalBookings'] ?? 0;
    final pendingBookings = dashboard!['pendingBookings'] ?? 0;
    final confirmedBookings = dashboard!['confirmedBookings'] ?? 0;

    final profileImage = owner!['profilePicture'];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ================= PROFILE HEADER =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🔹 IMAGE (NOW TAPPABLE FOR EDIT)
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OwnerEditProfileScreen(owner: owner!),
                      ),
                    );
                    _loadData();
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                    backgroundImage: profileImage != null &&
                            profileImage.toString().isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child:
                        profileImage == null || profileImage.toString().isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                  ),
                ),

                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      Text(phone,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statusBadge(status),
                          const SizedBox(width: 10),
                          Text(
                            'Joined: $joinedDate',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= DASHBOARD STATS =================
          Row(
            children: [
              _infoTile('Courts', totalCourts.toString(), Icons.sports_tennis),
              const SizedBox(width: 12),
              _infoTile(
                  'Bookings', totalBookings.toString(), Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoTile(
                  'Pending', pendingBookings.toString(), Icons.hourglass_top),
              const SizedBox(width: 12),
              _infoTile('Confirmed', confirmedBookings.toString(),
                  Icons.check_circle),
            ],
          ),

          const SizedBox(height: 32),

          // ================= ACTIONS =================
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OwnerEditProfileScreen(owner: owner!),
                        ),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.edit,
                        size: 18, color: AppColors.backgroundColor),
                    label: const Text('Edit Profile',
                        style: TextStyle(color: AppColors.backgroundColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await TokenService.clear();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                      );
                    },
                    icon: const Icon(Icons.logout,
                        size: 18, color: AppColors.backgroundColor),
                    label: const Text('Logout',
                        style: TextStyle(color: AppColors.backgroundColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'ACTIVE':
        color = Colors.green;
        break;
      case 'PENDING_APPROVAL':
        color = Colors.orange;
        break;
      default:
        color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
