import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tournaments = [];
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await TokenService.getUserId();
    await _fetchTournaments();
  }

  // ================= FETCH TOURNAMENTS =================
  Future<void> _fetchTournaments() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.get('/player/tournaments', token);
      final body = jsonDecode(res.body);

      final List list = body['data']?['tournaments'] ?? [];

      setState(() {
        _tournaments = List<Map<String, dynamic>>.from(list);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Fetch tournaments error: $e');
      setState(() => _loading = false);
    }
  }

  // ================= JOIN =================
  Future<void> _join(Map<String, dynamic> t) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await ApiService.post('/player/tournaments/${t['id']}/join', token, {});

      setState(() {
        t['participants'] ??= [];
        t['participants'].add({'playerId': _myUserId});
        t['currentParticipants'] = (t['currentParticipants'] ?? 0) + 1;
      });

      _snack('Joined tournament');
    } catch (_) {
      _error('Failed to join tournament');
    }
  }

  // ================= LEAVE =================
  Future<void> _leave(Map<String, dynamic> t) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await ApiService.post('/player/tournaments/${t['id']}/leave', token, {});

      setState(() {
        t['participants']?.removeWhere((p) => p['playerId'] == _myUserId);
        t['currentParticipants'] = (t['currentParticipants'] ?? 1) - 1;
      });

      _snack('Left tournament');
    } catch (_) {
      _error('Failed to leave tournament');
    }
  }

  // ================= HELPERS =================
  bool _isJoined(Map<String, dynamic> t) {
    final List participants = t['participants'] ?? [];
    return participants.any((p) => p['playerId'] == _myUserId);
  }

  bool _isFull(Map<String, dynamic> t) {
    final current = t['currentParticipants'] ?? 0;
    final max = t['maxParticipants'] ?? 0;
    return current >= max;
  }

  bool _isTeamSport(String? sport) {
    if (sport == null) return false;
    final s = sport.toLowerCase();
    return s == 'football' || s == 'cricket';
  }

  String _participantLabel(String? sport) {
    return _isTeamSport(sport) ? 'Teams' : 'Players';
  }

  String _formatDate(String date) {
    return DateTime.parse(date).toLocal().toString().split(' ')[0];
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Color _levelColor(String? level) {
    switch (level) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Tournaments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tournaments.isEmpty
              ? const Center(
                  child: Text(
                    'No tournaments available',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tournaments.length,
                  itemBuilder: (_, i) {
                    final t = _tournaments[i];
                    final joined = _isJoined(t);
                    final isFull = _isFull(t);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BADGES
                          Row(
                            children: [
                              if (joined) _badge('JOINED', Colors.green),
                              if (!joined && isFull) _badge('FULL', Colors.red),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // TITLE
                          Text(
                            t['name'] ?? 'Tournament',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),

                          const SizedBox(height: 6),
                          Text('Sport: ${t['sport']}'),

                          if (t['description'] != null &&
                              t['description'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                t['description'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatDate(t['startDate'])} → ${_formatDate(t['endDate'])}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '${_participantLabel(t['sport'])}: '
                            '${t['currentParticipants']} / ${t['maxParticipants']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          if (t['skillLevel'] != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _levelColor(t['skillLevel'])
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                t['skillLevel'],
                                style: TextStyle(
                                  color: _levelColor(t['skillLevel']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // ACTION BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: joined
                                  ? () => _leave(t)
                                  : isFull
                                      ? null
                                      : () => _join(t),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: joined
                                    ? Colors.red
                                    : isFull
                                        ? Colors.grey
                                        : AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                joined
                                    ? 'Leave Tournament'
                                    : isFull
                                        ? 'Tournament Full'
                                        : 'Join Tournament',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // ================= BADGE =================
  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
