import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class Player {
  final String id;
  final String name;
  final String email;
  String status;

  Player({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      email: json['email'],
      status: json['status'],
    );
  }
}

class ManagePlayersScreen extends StatefulWidget {
  final String adminToken;

  const ManagePlayersScreen({super.key, required this.adminToken});

  @override
  State<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  List<Player> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    final res = await ApiService.get(
      '/admin/users?role=PLAYER',
      widget.adminToken,
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body)['data']['users'] as List;
      setState(() {
        players = list.map((e) => Player.fromJson(e)).toList();
        isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(Player p, String status) async {
    await ApiService.put(
      '/admin/users/${p.id}/status',
      widget.adminToken,
      {'status': status},
    );
    setState(() => p.status = status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Manage Players', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (_, i) {
                final p = players[i];
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(p.email),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(p.status)),
                        if (p.status != 'ACTIVE')
                          TextButton(
                              onPressed: () => _updateStatus(p, 'ACTIVE'),
                              child: const Text('Activate')),
                        if (p.status == 'ACTIVE')
                          TextButton(
                              onPressed: () => _updateStatus(p, 'BLOCKED'),
                              child: const Text('Block')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
