import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final String sport;
  final String skillLevel;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final String status;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.sport,
    required this.skillLevel,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sport: json['sport'] ?? '',
      skillLevel: json['skillLevel'] ?? 'BEGINNER',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      status: json['status'] ?? 'UPCOMING',
    );
  }
}

class ManageTournamentsScreen extends StatefulWidget {
  final String adminToken;

  const ManageTournamentsScreen({
    super.key,
    required this.adminToken,
  });

  @override
  State<ManageTournamentsScreen> createState() =>
      _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  bool isLoading = true;
  List<Tournament> tournaments = [];

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  // ================= FETCH =================
  Future<void> _fetchTournaments() async {
    try {
      final res = await ApiService.get('/admin/tournaments', widget.adminToken);

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      final decoded = jsonDecode(res.body);
      final List list = decoded['data']['tournaments'] ?? [];

      setState(() {
        tournaments = list.map((e) => Tournament.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch tournaments error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= CORE LOGIC =================
  bool _isTeamSport(String sport) {
    final s = sport.toLowerCase();
    return s == 'football' || s == 'cricket';
  }

  bool _isFull(Tournament t) {
    return t.currentParticipants >= t.maxParticipants;
  }

  String _formatDate(DateTime d) => d.toLocal().toString().split(' ')[0];

  Future<void> _deleteTournament(String id) async {
    await ApiService.delete(
      '/admin/tournaments/$id',
      widget.adminToken,
    );
    _fetchTournaments();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Tournaments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tournaments.isEmpty
              ? const Center(child: Text('No tournaments found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tournaments.length,
                  itemBuilder: (_, i) {
                    final t = tournaments[i];
                    final isTeam = _isTeamSport(t.sport);
                    final isFull = _isFull(t);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingBlue,
                                    ),
                                  ),
                                ),
                                if (isFull)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'FULL',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text('${t.sport} • ${t.skillLevel}'),
                            Text(
                              '${_formatDate(t.startDate)} → ${_formatDate(t.endDate)}',
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 8),

                            // PARTICIPANTS / TEAMS
                            Text(
                              '${isTeam ? "Teams" : "Participants"}: '
                              '${t.currentParticipants} / ${t.maxParticipants}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ACTIONS
                            Row(
                              children: [
                                TextButton(
                                  onPressed:
                                      () {}, // edit dialog already exists
                                  child: const Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () => _deleteTournament(t.id),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
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
