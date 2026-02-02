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

  String _selectedSport = 'BADMINTON';
  String _message = '';

  final sports = ['BADMINTON', 'FOOTBALL', 'PADEL', 'CRICKET'];

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  // ================= FETCH PLAYERS =================
  Future<void> _fetchPlayers() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    final res = await ApiService.get('/player/players/search', token);
    final body = jsonDecode(res.body);

    if (body['success'] == true) {
      setState(() {
        _players =
            List<Map<String, dynamic>>.from(body['data']['players'] ?? []);
        _loading = false;
      });
    } else {
      setState(() {
        _players = [];
        _loading = false;
      });
    }
  }

  // ================= CHALLENGE DIALOG =================
  void _openChallengeDialog(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Challenge ${player['firstName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              value: _selectedSport,
              items: sports
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => _selectedSport = v!,
              decoration: const InputDecoration(labelText: 'Sport'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Message'),
              onChanged: (v) => _message = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendMatchRequest(player['id']);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // ================= SEND REQUEST =================
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Find Players',
          style: TextStyle(color: AppColors.backgroundColor),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? const Center(child: Text('No players found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _players.length,
                  itemBuilder: (_, i) {
                    final p = _players[i];

                    final sportsText = (p['sports'] as List)
                        .map((s) => '${s['sport']} (${s['skillLevel']})')
                        .join(', ');

                    final String? profilePic = p['profilePicture'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ================= PROFILE IMAGE =================
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.15),
                            backgroundImage:
                                (profilePic != null && profilePic.isNotEmpty)
                                    ? NetworkImage(profilePic)
                                    : null,
                            child: (profilePic == null || profilePic.isEmpty)
                                ? Text(
                                    p['firstName'] != null
                                        ? p['firstName'][0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                : null,
                          ),

                          const SizedBox(width: 12),

                          // ================= INFO =================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p['firstName']} ${p['lastName']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sportsText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ================= ACTION =================
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
