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
    List<Map<String, dynamic>> _matches = [];

    // FILTERS
    String _selectedSport = 'All';
    String _selectedTime = 'All';
    final TextEditingController _locationController = TextEditingController();

    final List<String> _sports = ['All', 'Badminton', 'Football', 'Padel', 'Cricket', 'Tennis'];
    final List<String> _times = ['All', 'Morning (6AM-12PM)', 'Afternoon (12PM-5PM)', 'Evening (5PM-9PM)', 'Night (9PM+)'];

    @override
    void initState() {
      super.initState();
      _fetchMatches();
    }

    @override
    void dispose() {
      _locationController.dispose();
      super.dispose();
    }

    // ================= FETCH MATCHES =================
    Future<void> _fetchMatches() async {
      final token = await TokenService.getToken();
      if (token == null) return;

      try {
        final res = await ApiService.get('/player/bookings/available-matches', token);
        final body = jsonDecode(res.body);

        if (mounted) {
          if (body['success'] == true) {
            setState(() {
              _matches = List<Map<String, dynamic>>.from(body['data']['bookings'] ?? []);
              _loading = false;
            });
          } else {
            setState(() {
              _matches = [];
              _loading = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Fetch matches error: $e');
        if (mounted) setState(() => _loading = false);
      }
    }

    // ================= JOIN MATCH =================
    Future<void> _joinMatch(Map<String, dynamic> match) async {
  final token = await TokenService.getToken();
  if (token == null) return;
  
  String? targetTeam;
  
  if (match['matchType'] == 'DOUBLES') {
    final participants = match['participants'] as List? ?? [];
    final teamACount = participants.where((p) => p['team'] == 'TEAM_A').length;
    
    if (teamACount == 1) {
      targetTeam = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Join Match"),
          content: const Text("Would you like to join as a partner or as an opponent?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'TEAM_A'),
              child: const Text('Partner (Team A)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'TEAM_B'),
              child: const Text('Opponent (Team B)'),
            ),
          ],
        )
      );
      
      if (targetTeam == null) return; 
    }
  }

  try {
    // FIX: Explicitly define the map type here
    final Map<String, dynamic> payload = targetTeam != null ? {'team': targetTeam} : {};
    
    final res = await ApiService.post('/player/bookings/${match['id']}/join', token, payload);
    final body = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined match!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _fetchMatches();
    } else {
      throw Exception(body['message'] ?? 'Failed to join match');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

    // ================= HELPERS =================
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

    // ================= UI COMPONENTS =================
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

    Widget _buildFilters() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Column(
          children: [
            // Search by Location
            TextField(
              controller: _locationController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search by location or court...',
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSport,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                        items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSport = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTime,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                        items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTime = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> get _filteredMatches {
      return _matches.where((m) {
        if (_selectedSport != 'All' && m['sport']?.toString().toUpperCase() != _selectedSport.toUpperCase()) {
          return false;
        }

        final locQuery = _locationController.text.toLowerCase().trim();
        if (locQuery.isNotEmpty) {
          final court = m['court'] ?? {};
          final cName = court['name']?.toString().toLowerCase() ?? '';
          final cLoc = court['location']?.toString().toLowerCase() ?? '';
          if (!cName.contains(locQuery) && !cLoc.contains(locQuery)) {
            return false;
          }
        }

        if (_selectedTime != 'All') {
          final startTime = m['startTime']?.toString() ?? '00:00';
          final hour = int.tryParse(startTime.split(':')[0]) ?? 0;
          if (_selectedTime == 'Morning (6AM-12PM)' && (hour < 6 || hour >= 12)) return false;
          if (_selectedTime == 'Afternoon (12PM-5PM)' && (hour < 12 || hour >= 17)) return false;
          if (_selectedTime == 'Evening (5PM-9PM)' && (hour < 17 || hour >= 21)) return false;
          if (_selectedTime == 'Night (9PM+)' && (hour >= 6 && hour < 21)) return false;
        }
        return true;
      }).toList();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          title: const Text(
            'Find Matches',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _fetchMatches(), // Fixed: wrapped in anonymous function
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMatches, 
                color: AppColors.primaryColor,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredMatches.isEmpty
                    ? ListView( 
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(child: Text('No active matches found.\nAdjust filters or pull down to refresh.', textAlign: TextAlign.center)),
                  ],
                )
                    : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredMatches.length,
                  itemBuilder: (_, i) {
                    final m = _filteredMatches[i];
              final String? profilePic = m['player']['profilePicture'];
              final String hostName = m['player']['firstName'] ?? 'Player';
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_formatDate(m['date'])} | ${m['startTime']} - ${m['endTime']}",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${m['court']['name']}",
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Builder(
                                builder: (context) {
                                  if (isDoubles) {
                                    final pCount = (m['participants'] as List?)?.length ?? 0;
                                    final spaces = 4 - pCount;
                                    return Text(spaces == 1 ? "1 Space Left" : "$spaces Spaces Left", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold));
                                  } else {
                                    return Text("Waiting for Opponent", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold));
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TEAMS SECTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Builder(builder: (context) {
                          List<Widget> teamAWidgets = [];
                          List<Widget> teamBWidgets = [];

                          if (isDoubles) {
                            final participants = m['participants'] as List? ?? [];
                            final teamA = participants.where((p) => p['team'] == 'TEAM_A').toList();
                            final teamB = participants.where((p) => p['team'] == 'TEAM_B').toList();

                            for (var i = 0; i < 2; i++) {
                              if (i < teamA.length) {
                                final pInfo = teamA[i]['player'];
                                teamAWidgets.add(_playerAvatar(pInfo['firstName'] ?? 'Player', pInfo['profilePicture']));
                              } else {
                                teamAWidgets.add(_emptyAvatar());
                              }

                              if (i < teamB.length) {
                                final pInfo = teamB[i]['player'];
                                teamBWidgets.add(_playerAvatar(pInfo['firstName'] ?? 'Player', pInfo['profilePicture']));
                              } else {
                                teamBWidgets.add(_emptyAvatar());
                              }
                            }
                          } else {
                            // Singular or Team Captain logic
                            teamAWidgets.add(_playerAvatar(hostName, profilePic));
                            teamBWidgets.add(_emptyAvatar());
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: teamAWidgets.map((w) => Expanded(child: w)).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(isDoubles ? "Team A" : "Host", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: teamBWidgets.map((w) => Expanded(child: w)).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(isDoubles ? "Team B" : "Opponent", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // BOTTOM BAR
                      Container(
                        color: const Color(0xFF0F172A),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Wrapping text in Expanded prevents the "57 pixels overflow"
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Constrain height
                                children: [
                                  Text(
                                    "${m['sport']} • $formatTitle • Level All",
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis, // Agar text lamba ho to dots (...) aa jayein
                                    maxLines: 2,
                                  ),
                                  Text(
                                    "$priceText | $mins min",
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Thodi space button aur text ke darmiyan
                            ElevatedButton(
                              onPressed: () => _joinMatch(m),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                visualDensity: VisualDensity.compact, // Button ko thoda slim rakhta hai
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Join Match', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
                ),
          ),
            ),
          ],
        ),
      );
    }
  }