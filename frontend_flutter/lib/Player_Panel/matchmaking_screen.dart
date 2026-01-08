import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _players = [];

  String _selectedSport = 'Badminton';
  String _message = '';

  final sports = ['Badminton', 'Tennis', 'Cricket', 'Squash'];

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    final res = await ApiService.get('/player/players/search', token);

    final body = jsonDecode(res.body);
    final List list = body['data']['players'];

    setState(() {
      _players = List<Map<String, dynamic>>.from(list);
      _loading = false;
    });
  }

  void _openChallengeDialog(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Challenge ${player['firstName']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              value: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Sport',
              ),
              items: sports
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => _selectedSport = v!,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message (date/time suggestion)',
              ),
              onChanged: (v) => _message = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendMatchRequest(player['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMatchRequest(String receiverId) async {
    final token = await TokenService.getToken();

    await ApiService.post('/player/match-requests', token!, {
      'receiverId': receiverId,
      'sport': _selectedSport,
      'message': _message,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Find Players',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? const Center(
                  child: Text(
                    'No players found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _players.length,
                  itemBuilder: (_, i) {
                    final p = _players[i];
                    final initials =
                        '${p['firstName'][0]}${p['lastName']?[0] ?? ''}'
                            .toUpperCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.15),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p['firstName']} ${p['lastName']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Skill level: ${p['skillLevel'] ?? 'N/A'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _openChallengeDialog(p),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Challenge',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
