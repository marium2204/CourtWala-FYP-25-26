import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class CourtOwner {
  final String id;
  final String name;
  final String email;
  String status;
  final int courts;

  CourtOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.courts,
  });

  factory CourtOwner.fromJson(Map<String, dynamic> json) {
    return CourtOwner(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      email: json['email'],
      status: json['status'],
      courts: json['courtsCount'] ?? 0,
    );
  }
}

class ManageOwnersScreen extends StatefulWidget {
  final String adminToken;

  const ManageOwnersScreen({super.key, required this.adminToken});

  @override
  State<ManageOwnersScreen> createState() => _ManageOwnersScreenState();
}

class _ManageOwnersScreenState extends State<ManageOwnersScreen> {
  List<CourtOwner> owners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  Future<void> _fetchOwners() async {
    try {
      final res = await ApiService.get(
        '/admin/users?role=COURT_OWNER',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['users'] ?? [];

        setState(() {
          owners = list.map((e) => CourtOwner.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch owners error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _approveOwner(CourtOwner owner) async {
    try {
      final res = await ApiService.post(
        '/admin/owners/${owner.id}/approve',
        widget.adminToken,
        {},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner approved')),
        );
        _fetchOwners(); // ✅ REFRESH
      }
    } catch (e) {
      debugPrint('Approve owner error: $e');
    }
  }

  Future<void> _rejectOwner(CourtOwner owner) async {
    try {
      final res = await ApiService.post(
        '/admin/owners/${owner.id}/reject',
        widget.adminToken,
        {'reason': 'Rejected by admin'},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner rejected')),
        );
        _fetchOwners(); // ✅ REFRESH
      }
    } catch (e) {
      debugPrint('Reject owner error: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Court Owners',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : owners.isEmpty
              ? const Center(child: Text('No court owners found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: owners.length,
                  itemBuilder: (_, i) {
                    final o = owners[i];
                    return Card(
                      child: ListTile(
                        title: Text(o.name),
                        subtitle: Text(o.email),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(o.status),
                              backgroundColor:
                                  _statusColor(o.status).withOpacity(0.15),
                            ),
                            if (o.status == 'PENDING')
                              TextButton(
                                onPressed: () => _approveOwner(o),
                                child: const Text('Approve'),
                              ),
                            if (o.status == 'PENDING')
                              TextButton(
                                onPressed: () => _rejectOwner(o),
                                child: const Text('Reject'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
