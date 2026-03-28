import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMyMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyMatches() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/player/bookings', token);
      final body = jsonDecode(res.body);

      if (body['success'] == true) {
        final List allBookings = body['data']['bookings'] ?? [];
        
        // Filter only matches (matchType != null)
        final matches = allBookings
            .where((b) => b['matchType'] != null)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          _matches = matches;
          _loading = false;
        });
      } else {
        setState(() {
          _matches = [];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch my matches error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String isoString) {
    try {
      final d = DateTime.parse(isoString);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}";
    } catch (_) {
      return isoString;
    }
  }

  int _getDurationMinutes(String start, String end) {
    try {
      final sParts = start.split(':');
      final eParts = end.split(':');
      final sMins = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
      final eMins = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);
      return eMins - sMins;
    } catch (e) {
      return 60;
    }
  }

  Widget _playerAvatar(String name, String? profilePic) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryColor.withOpacity(0.15),
          backgroundImage: (profilePic != null && profilePic.isNotEmpty)
              ? NetworkImage(profilePic)
              : null,
          child: (profilePic == null || profilePic.isEmpty)
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryColor),
                )
              : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }

  Widget _emptyAvatar() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid),
          ),
          child: const Icon(Icons.add, color: Colors.grey, size: 24),
        ),
        const SizedBox(height: 8),
        const Text("Available", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMatchList(List<Map<String, dynamic>> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return const Center(child: Text('No matches found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        
        // Host (Team A)
        final host = m['player'] ?? {};
        final String hostName = host['firstName'] ?? 'Player';
        final String? hostPic = host['profilePicture'];

        // Opponent (Team B)
        final opponent = m['opponent'];
        final String opponentName = opponent != null ? (opponent['firstName'] ?? 'Player') : '';
        final String? opponentPic = opponent != null ? opponent['profilePicture'] : null;

        final bool isDoubles = m['matchType'] == 'DOUBLES';
        
        final double total = m['totalPrice'] != null ? double.tryParse(m['totalPrice'].toString()) ?? 0 : 0;
        String priceText = '';
        String formatTitle = '';

        if (m['matchType'] == 'TEAM') {
          final int pps = m['playersPerSide'] ?? 5;
          formatTitle = '${pps}v$pps Match';
          priceText = "Rs ${(total / 2).toStringAsFixed(0)}/team";
        } else if (isDoubles) {
          formatTitle = 'Doubles Match';
          priceText = "Rs ${(total / 4).toStringAsFixed(0)}/player";
        } else {
          formatTitle = 'Singles Match';
          priceText = "Rs ${(total / 2).toStringAsFixed(0)}/player";
        }

        final int mins = _getDurationMinutes(m['startTime'] ?? '00:00', m['endTime'] ?? '00:00');
        
        final isConfirmed = m['status'] == 'CONFIRMED';
        final Color statusBg = isConfirmed ? Colors.green.shade50 : Colors.orange.shade50;
        final Color statusTextCol = isConfirmed ? Colors.green.shade700 : Colors.orange.shade700;
        final String statusText = m['status'] == 'PENDING_APPROVAL' ? 'Pending' : (m['status'] ?? 'Match');

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_formatDate(m['date'] ?? '')} | ${m['startTime']} - ${m['endTime']}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${m['court']?['name'] ?? ''}",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(statusText, style: TextStyle(color: statusTextCol, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // TEAMS SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _playerAvatar(hostName, hostPic),
                                if (isDoubles) _emptyAvatar(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text("Team A", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                opponent != null 
                                    ? _playerAvatar(opponentName, opponentPic)
                                    : _emptyAvatar(),
                                if (isDoubles) _emptyAvatar(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text("Team B", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // BOTTOM BAR
                Container(
                  color: const Color(0xFF0F172A),
                  width: double.infinity, // Poori width le lega
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${m['sport'] ?? ''} • $formatTitle • Level All",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$priceText | $mins min",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Start of current day to ensure we don't accidentally class today's earlier matches as recent improperly unless desired.
    // However typically date parsing direct comparison handles this.
    
    final upcomingMatches = _matches.where((m) {
      if (m['date'] == null) return false;
      try {
        final d = DateTime.parse(m['date']);
        // If date + time is strictly before now, it's recent. 
        // For simplicity, we just compare Date.
        final matchDateEnd = DateTime(d.year, d.month, d.day, 23, 59);
        return matchDateEnd.isAfter(now);
      } catch (_) { return false; }
    }).toList();

    final recentMatches = _matches.where((m) {
      if (m['date'] == null) return false;
      try {
        final d = DateTime.parse(m['date']);
        final matchDateEnd = DateTime(d.year, d.month, d.day, 23, 59);
        return matchDateEnd.isBefore(now);
      } catch (_) { return false; }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('My Matches', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(_matches),
          _buildMatchList(upcomingMatches),
          _buildMatchList(recentMatches),
        ],
      ),
    );
  }
}
