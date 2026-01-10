import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  String status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString().toUpperCase() ?? 'PLAYER';

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      role: rawRole == 'COURT_OWNER' ? 'OWNER' : rawRole,
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
    );
  }
}

class ManageUsersScreen extends StatefulWidget {
  final String adminToken;

  const ManageUsersScreen({super.key, required this.adminToken});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> allUsers = [];
  String selectedRole = 'ALL';
  bool isLoading = true;

  final List<String> roles = ['ALL', 'PLAYER', 'OWNER', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final res = await ApiService.get(
        '/admin/users',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = decoded['data']['users'] as List;

        setState(() {
          allUsers = list.map((e) => UserModel.fromJson(e)).toList();
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

  Future<void> _updateStatus(UserModel user, String status) async {
    try {
      await ApiService.put(
        '/admin/users/${user.id}/status',
        widget.adminToken,
        {'status': status},
      );

      setState(() => user.status = status);
    } catch (e) {
      debugPrint('Update status error: $e');
    }
  }

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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: AppColors.white,
                            onSelected: (_) =>
                                setState(() => selectedRole = role),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
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
                          itemBuilder: (_, i) {
                            final u = filteredUsers[i];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          u.name.isEmpty
                                              ? 'Unnamed User'
                                              : u.name,
                                          style: AppTextStyles.title,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _roleColor(u.role)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          u.role,
                                          style: TextStyle(
                                            color: _roleColor(u.role),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(u.email, style: AppTextStyles.subtitle),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _statusColor(u.status)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          u.status,
                                          style: TextStyle(
                                            color: _statusColor(u.status),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (u.status != 'ACTIVE')
                                        TextButton(
                                          onPressed: () =>
                                              _updateStatus(u, 'ACTIVE'),
                                          child: const Text('Activate'),
                                        ),
                                      if (u.status != 'SUSPENDED')
                                        TextButton(
                                          onPressed: () =>
                                              _updateStatus(u, 'SUSPENDED'),
                                          child: const Text('Suspend'),
                                        ),
                                      if (u.status != 'BLOCKED')
                                        TextButton(
                                          onPressed: () =>
                                              _updateStatus(u, 'BLOCKED'),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Block'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
