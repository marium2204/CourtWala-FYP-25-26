import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
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
    return UserModel(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      email: json['email'],
      role: json['role'],
      status: json['status'],
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
    await ApiService.put(
      '/admin/users/${user.id}/status',
      widget.adminToken,
      {'status': status},
    );

    setState(() => user.status = status);
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
      appBar: AppBar(
        title:
            const Text('Manage Users', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔽 Role Filter
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: roles.map((role) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(role),
                            selected: selectedRole == role,
                            onSelected: (_) =>
                                setState(() => selectedRole = role),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 📋 User Cards
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredUsers.length,
                          itemBuilder: (_, i) {
                            final u = filteredUsers[i];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name + Role
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            u.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
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
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      u.email,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Status + Actions
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
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
                                            child: const Text(
                                              'Block',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
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
