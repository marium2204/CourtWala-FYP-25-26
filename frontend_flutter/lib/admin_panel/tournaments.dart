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
  String status;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.sport,
    required this.skillLevel,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.status,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sport: json['sport'] ?? '',
      skillLevel: json['skillLevel'] ?? 'BEGINNER',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxParticipants: json['maxParticipants'] ?? 0,
      status: json['status'] ?? 'UPCOMING',
    );
  }
}

class ManageTournamentsScreen extends StatefulWidget {
  final String adminToken;

  const ManageTournamentsScreen({super.key, required this.adminToken});

  @override
  State<ManageTournamentsScreen> createState() =>
      _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  List<Tournament> tournaments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    try {
      final res = await ApiService.get('/admin/tournaments', widget.adminToken);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['tournaments'] ?? [];

        setState(() {
          tournaments = list.map((e) => Tournament.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch tournaments error: $e');
      setState(() => isLoading = false);
    }
  }

  void _openForm({Tournament? tournament}) {
    final isEdit = tournament != null;

    final nameCtrl = TextEditingController(text: tournament?.name ?? '');
    final descCtrl = TextEditingController(text: tournament?.description ?? '');
    final sportCtrl = TextEditingController(text: tournament?.sport ?? '');
    final maxCtrl = TextEditingController(
        text: tournament?.maxParticipants.toString() ?? '');

    String skillLevel = tournament?.skillLevel ?? 'BEGINNER';
    String status = tournament?.status ?? 'UPCOMING';
    DateTime? startDate = tournament?.startDate;
    DateTime? endDate = tournament?.endDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Tournament' : 'Create Tournament'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Description')),
                  TextField(
                      controller: sportCtrl,
                      decoration: const InputDecoration(labelText: 'Sport')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: skillLevel,
                    decoration: const InputDecoration(labelText: 'Skill Level'),
                    items: const [
                      DropdownMenuItem(
                          value: 'BEGINNER', child: Text('BEGINNER')),
                      DropdownMenuItem(
                          value: 'INTERMEDIATE', child: Text('INTERMEDIATE')),
                      DropdownMenuItem(
                          value: 'ADVANCED', child: Text('ADVANCED')),
                    ],
                    onChanged: (v) => setDialogState(() => skillLevel = v!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setDialogState(() => startDate = d);
                          }
                        },
                        child: Text(startDate == null
                            ? 'Pick Start Date'
                            : startDate!.toLocal().toString().split(' ')[0]),
                      ),
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setDialogState(() => endDate = d);
                          }
                        },
                        child: Text(endDate == null
                            ? 'Pick End Date'
                            : endDate!.toLocal().toString().split(' ')[0]),
                      ),
                    ],
                  ),
                  TextField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Participants'),
                  ),
                  if (isEdit)
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                            value: 'UPCOMING', child: Text('UPCOMING')),
                        DropdownMenuItem(
                            value: 'ONGOING', child: Text('ONGOING')),
                        DropdownMenuItem(
                            value: 'COMPLETED', child: Text('COMPLETED')),
                      ],
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      descCtrl.text.isEmpty ||
                      sportCtrl.text.isEmpty ||
                      startDate == null ||
                      endDate == null ||
                      maxCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fill all fields')),
                    );
                    return;
                  }

                  final body = {
                    'name': nameCtrl.text,
                    'description': descCtrl.text,
                    'sport': sportCtrl.text,
                    'skillLevel': skillLevel,
                    'startDate': startDate!.toIso8601String(),
                    'endDate': endDate!.toIso8601String(),
                    'maxParticipants': int.parse(maxCtrl.text),
                    if (isEdit) 'status': status,
                  };

                  Navigator.pop(context);

                  if (isEdit) {
                    await ApiService.put(
                      '/admin/tournaments/${tournament.id}',
                      widget.adminToken,
                      body,
                    );
                  } else {
                    await ApiService.post(
                      '/admin/tournaments',
                      widget.adminToken,
                      body,
                    );
                  }

                  _fetchTournaments();
                },
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteTournament(String id) async {
    await ApiService.delete(
      '/admin/tournaments/$id',
      widget.adminToken,
    );
    _fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tournaments',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(t.name),
                        subtitle: Text(
                            '${t.sport} | ${t.skillLevel}\n${t.startDate.toLocal().toString().split(' ')[0]} → ${t.endDate.toLocal().toString().split(' ')[0]}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                                onPressed: () => _openForm(tournament: t),
                                child: const Text('Edit')),
                            TextButton(
                              onPressed: () => _deleteTournament(t.id),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Delete'),
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
