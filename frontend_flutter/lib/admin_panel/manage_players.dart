import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ManagePlayersScreen extends StatefulWidget {
  const ManagePlayersScreen({super.key});

  @override
  State<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  List<Map<String, dynamic>> players = [
    {
      'name': 'Ahmed Ali',
      'email': 'ahmed@example.com',
      'status': 'Active',
      'bookings': 12,
    },
    {
      'name': 'Sara Malik',
      'email': 'sara@example.com',
      'status': 'Blocked',
      'bookings': 5,
    },
    {
      'name': 'Omar Khan',
      'email': 'omar@example.com',
      'status': 'Active',
      'bookings': 8,
    },
    {
      'name': 'Fatima Noor',
      'email': 'fatima@example.com',
      'status': 'Active',
      'bookings': 3,
    },
  ];

  void _blockPlayer(int index) {
    setState(() {
      players[index]['status'] = 'Blocked';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${players[index]['name']} blocked')),
    );
  }

  void _unblockPlayer(int index) {
    setState(() {
      players[index]['status'] = 'Active';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${players[index]['name']} unblocked')),
    );
  }

  void _viewBookings(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('${players[index]['name']} - Bookings'),
            content: Text(
                'This player has ${players[index]['bookings']} booking(s).'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Players',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: players.isEmpty
          ? const Center(child: Text('No players available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.accentColor,
                                child: Text(player['name'][0],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(player['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.headingBlue)),
                                    const SizedBox(height: 4),
                                    Text(player['email'],
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: player['status'] == 'Active'
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(player['status'],
                                    style: TextStyle(
                                        color: player['status'] == 'Active'
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => _viewBookings(index),
                                icon:
                                    const Icon(Icons.calendar_today, size: 18),
                                label: const Text('View Bookings'),
                              ),
                              if (player['status'] != 'Blocked')
                                TextButton.icon(
                                  onPressed: () => _blockPlayer(index),
                                  icon: const Icon(Icons.block, size: 18),
                                  label: const Text('Block'),
                                ),
                              if (player['status'] == 'Blocked')
                                TextButton.icon(
                                  onPressed: () => _unblockPlayer(index),
                                  icon:
                                      const Icon(Icons.check_circle, size: 18),
                                  label: const Text('Unblock'),
                                ),
                            ],
                          ),
                        ]),
                  ),
                );
              },
            ),
    );
  }
}
