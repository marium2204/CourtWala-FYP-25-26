import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

/* =========================
   USER MODEL (SAFE + NORMALIZED)
========================= */
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // PLAYER | OWNER | ADMIN
  String status;
  final DateTime joinedAt;

  final int courtsOwned;
  final int bookingsMade;
  final int bookingsReceived;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.courtsOwned,
    required this.bookingsMade,
    required this.bookingsReceived,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};

    // ✅ Normalize role ONCE
    final rawRole = json['role']?.toString() ?? 'PLAYER';
    final normalizedRole = rawRole == 'COURT_OWNER' ? 'OWNER' : rawRole;

    // ✅ Safe date parse
    DateTime joined;
    try {
      joined = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();
    } catch (_) {
      joined = DateTime.now();
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name']
          : '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'
                  .trim()
                  .isNotEmpty
              ? '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim()
              : 'Unnamed User',
      email: json['email']?.toString() ?? 'N/A',
      role: normalizedRole,
      status: json['status']?.toString() ?? 'ACTIVE',
      joinedAt: joined,
      courtsOwned: stats['courtsOwned'] ?? 0,
      bookingsMade: stats['bookingsMade'] ?? 0,
      bookingsReceived: stats['bookingsReceived'] ?? 0,
    );
  }
}

/* =========================
   SCREEN
========================= */
class ManageUsersScreen extends StatefulWidget {
  final String adminToken;

  const ManageUsersScreen({super.key, required this.adminToken});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> allUsers = [];
  bool isLoading = true;
  String selectedRole = 'ALL';

  final roles = ['ALL', 'PLAYER', 'OWNER', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /* =========================
     FETCH USERS
  ========================= */
  Future<void> _fetchUsers() async {
    try {
      final res = await ApiService.get(
        '/admin/users',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = decoded['data']?['users'] ?? [];

        setState(() {
          allUsers = List<Map<String, dynamic>>.from(list)
              .map(UserModel.fromJson)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch users error: $e');
      setState(() => isLoading = false);
    }
  }

  /* =========================
     UPDATE STATUS
  ========================= */
  Future<void> _updateStatus(UserModel user, String status) async {
    await ApiService.put(
      '/admin/users/${user.id}/status',
      widget.adminToken,
      {'status': status},
    );
    setState(() => user.status = status);
  }

  /* =========================
     FILTERING (FIXED)
  ========================= */
  List<UserModel> get filteredUsers {
    if (selectedRole == 'ALL') return allUsers;
    return allUsers.where((u) => u.role == selectedRole).toList();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.redAccent;
      case 'OWNER':
        return Colors.blueAccent;
      case 'PLAYER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'SUSPENDED':
        return Colors.orange;
      case 'BLOCKED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  /* =========================
     UI
  ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title:
            const Text('Manage Users', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _roleFilter(),
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            'No users found',
                            style: AppTextStyles.subtitle,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (_, i) => _userCard(filteredUsers[i]),
                        ),
                ),
              ],
            ),
    );
  }

  /* =========================
     ROLE FILTER
  ========================= */
  Widget _roleFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: roles.map((role) {
            final selected = selectedRole == role;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  role,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                selectedColor: AppColors.primaryColor,
                backgroundColor: Colors.white,
                onSelected: (_) => setState(() => selectedRole = role),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /* =========================
     USER CARD
  ========================= */
  Widget _userCard(UserModel u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + ROLE
          Row(
            children: [
              Expanded(
                child: Text(u.name, style: AppTextStyles.title),
              ),
              _pill(u.role, _roleColor(u.role)),
            ],
          ),

          const SizedBox(height: 6),
          Text(u.email, style: AppTextStyles.subtitle),

          const SizedBox(height: 12),

          // STATS (NO REVIEWS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (u.role == 'OWNER') _stat('Courts', u.courtsOwned),
              if (u.role == 'OWNER') _stat('Bookings', u.bookingsReceived),
              if (u.role == 'PLAYER') _stat('Bookings', u.bookingsMade),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Joined: ${u.joinedAt.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _pill(u.status, _statusColor(u.status)),
              const Spacer(),
              if (u.status != 'ACTIVE')
                TextButton(
                  onPressed: () => _updateStatus(u, 'ACTIVE'),
                  child: const Text('Activate'),
                ),
              if (u.status != 'SUSPENDED')
                TextButton(
                  onPressed: () => _updateStatus(u, 'SUSPENDED'),
                  child: const Text('Suspend'),
                ),
              if (u.status != 'BLOCKED')
                TextButton(
                  onPressed: () => _updateStatus(u, 'BLOCKED'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Block'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /* =========================
     HELPERS
  ========================= */
  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
