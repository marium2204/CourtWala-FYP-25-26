import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ManageTournamentsScreen extends StatefulWidget {
  const ManageTournamentsScreen({super.key});

  @override
  State<ManageTournamentsScreen> createState() =>
      _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  List<Map<String, dynamic>> tournaments = [
    {
      'name': 'City Badminton Championship',
      'description': 'Annual city level badminton tournament.',
      'sport': 'Badminton',
      'skillLevel': 'INTERMEDIATE',
      'startDate': '2025-12-05',
      'endDate': '2025-12-10',
      'maxParticipants': 32,
      'status': 'UPCOMING',
    },
    {
      'name': 'Summer Tennis Open',
      'description': 'Open level tennis competition for all.',
      'sport': 'Tennis',
      'skillLevel': 'BEGINNER',
      'startDate': '2025-11-20',
      'endDate': '2025-11-25',
      'maxParticipants': 16,
      'status': 'ONGOING',
    },
  ];

  void _openTournamentForm({int? index}) {
    bool isEdit = index != null;
    final tournament = isEdit ? tournaments[index] : {};
    final nameController = TextEditingController(text: tournament['name']);
    final descriptionController =
        TextEditingController(text: tournament['description']);
    final sportController = TextEditingController(text: tournament['sport']);
    String skillLevel = tournament['skillLevel'] ?? 'BEGINNER';
    String status = tournament['status'] ?? 'UPCOMING';
    DateTime? startDate =
        isEdit ? DateTime.parse(tournament['startDate']) : null;
    DateTime? endDate = isEdit ? DateTime.parse(tournament['endDate']) : null;
    final maxParticipantsController =
        TextEditingController(text: tournament['maxParticipants']?.toString());

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Tournament' : 'Create Tournament'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sportController,
                    decoration: const InputDecoration(labelText: 'Sport'),
                  ),
                  const SizedBox(height: 12),
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
                    onChanged: (value) =>
                        setStateDialog(() => skillLevel = value!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setStateDialog(() => startDate = picked);
                            }
                          },
                          child: Text(startDate == null
                              ? 'Select Start Date'
                              : 'Start: ${startDate!.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setStateDialog(() => endDate = picked);
                            }
                          },
                          child: Text(endDate == null
                              ? 'Select End Date'
                              : 'End: ${endDate!.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Participants'),
                  ),
                  const SizedBox(height: 12),
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
                      onChanged: (value) =>
                          setStateDialog(() => status = value!),
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
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      sportController.text.isEmpty ||
                      startDate == null ||
                      endDate == null ||
                      maxParticipantsController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please fill all required fields')));
                    return;
                  }

                  final tournamentData = {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'sport': sportController.text,
                    'skillLevel': skillLevel,
                    'startDate': startDate!.toIso8601String(),
                    'endDate': endDate!.toIso8601String(),
                    'maxParticipants':
                        int.tryParse(maxParticipantsController.text) ?? 0,
                    'status': status,
                  };

                  setState(() {
                    if (isEdit) {
                      tournaments[index] = tournamentData;
                    } else {
                      tournaments.add(tournamentData);
                    }
                  });

                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteTournament(int index) {
    setState(() {
      tournaments.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tournament deleted')));
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
      body: tournaments.isEmpty
          ? const Center(child: Text('No tournaments available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tournaments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tournament = tournaments[index];
                Color statusColor;
                switch (tournament['status']) {
                  case 'ONGOING':
                    statusColor = Colors.orange;
                    break;
                  case 'COMPLETED':
                    statusColor = Colors.green;
                    break;
                  default:
                    statusColor = Colors.blue;
                }

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tournament['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.headingBlue)),
                        const SizedBox(height: 4),
                        Text(tournament['description'],
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                            'Sport: ${tournament['sport']} | Skill: ${tournament['skillLevel']}',
                            style: const TextStyle(color: Colors.grey)),
                        Text(
                            'Dates: ${tournament['startDate'].split('T')[0]} - ${tournament['endDate'].split('T')[0]}',
                            style: const TextStyle(color: Colors.grey)),
                        Text(
                            'Max Participants: ${tournament['maxParticipants']}',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(tournament['status'],
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _openTournamentForm(index: index),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _deleteTournament(index),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => _openTournamentForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
