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
            ),
            const SizedBox(height: 10),
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
      backgroundColor: AppColors.backgroundBeige,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _players.length,
              itemBuilder: (_, i) {
                final p = _players[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(p['firstName'][0]),
                    ),
                    title: Text('${p['firstName']} ${p['lastName']}'),
                    subtitle: Text('Level: ${p['skillLevel'] ?? 'N/A'}'),
                    trailing: ElevatedButton(
                      onPressed: () => _openChallengeDialog(p),
                      child: const Text('Challenge'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
