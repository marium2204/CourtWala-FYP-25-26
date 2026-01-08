import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Tournaments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tournaments.isEmpty
              ? Center(
                  child: Text(
                    'No tournaments found',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tournaments.length,
                  itemBuilder: (_, i) {
                    final t = tournaments[i];
                    final isTeam = _isTeamSport(t.sport);
                    final isFull = _isFull(t);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
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
                          /// =========================
                          /// Header
                          /// =========================
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.name,
                                  style: AppTextStyles.title,
                                ),
                              ),
                              if (isFull)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'FULL',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// =========================
                          /// Meta
                          /// =========================
                          Text(
                            '${t.sport} • ${t.skillLevel}',
                            style: AppTextStyles.subtitle,
                          ),
                          Text(
                            '${_formatDate(t.startDate)} → ${_formatDate(t.endDate)}',
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 13),
                          ),

                          const SizedBox(height: 12),

                          /// =========================
                          /// Participants
                          /// =========================
                          Text(
                            '${isTeam ? "Teams" : "Participants"}: '
                            '${t.currentParticipants} / ${t.maxParticipants}',
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// =========================
                          /// Actions
                          /// =========================
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _deleteTournament(t.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
