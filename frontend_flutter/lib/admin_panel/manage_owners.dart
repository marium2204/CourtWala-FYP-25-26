// lib/Admin_Panel/manage_owners_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ManageOwnersScreen extends StatefulWidget {
  const ManageOwnersScreen({super.key});

  @override
  State<ManageOwnersScreen> createState() => _ManageOwnersScreenState();
}

class _ManageOwnersScreenState extends State<ManageOwnersScreen> {
  // Sample owners data (replace with backend)
  List<Map<String, dynamic>> owners = [
    {
      'name': 'Ali Ahmed',
      'email': 'ali@example.com',
      'status': 'Pending',
      'courts': 2,
    },
    {
      'name': 'Sara Khan',
      'email': 'sara@example.com',
      'status': 'Approved',
      'courts': 5,
    },
    {
      'name': 'Omar Riaz',
      'email': 'omar@example.com',
      'status': 'Suspended',
      'courts': 1,
    },
    {
      'name': 'Fatima Noor',
      'email': 'fatima@example.com',
      'status': 'Approved',
      'courts': 3,
    },
  ];

  void _approveOwner(int index) {
    setState(() {
      owners[index]['status'] = 'Approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${owners[index]['name']} approved')),
    );
  }

  void _suspendOwner(int index) {
    setState(() {
      owners[index]['status'] = 'Suspended';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${owners[index]['name']} suspended')),
    );
  }

  void _viewCourts(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('${owners[index]['name']} - Courts'),
            content: Text(
                'This owner has ${owners[index]['courts']} court(s) registered.'),
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
          'Manage Owners',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: owners.isEmpty
          ? const Center(child: Text('No owners available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: owners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final owner = owners[index];
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
                                child: Text(owner['name'][0],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(owner['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.headingBlue)),
                                    const SizedBox(height: 4),
                                    Text(owner['email'],
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: owner['status'] == 'Approved'
                                        ? Colors.green[100]
                                        : owner['status'] == 'Pending'
                                            ? Colors.orange[100]
                                            : Colors.red[100],
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(owner['status'],
                                    style: TextStyle(
                                        color: owner['status'] == 'Approved'
                                            ? Colors.green[800]
                                            : owner['status'] == 'Pending'
                                                ? Colors.orange[800]
                                                : Colors.red[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _viewCourts(index),
                                icon: const Icon(Icons.sports_tennis, size: 18),
                                label: const Text('View Courts'),
                              ),
                              const SizedBox(width: 8),
                              if (owner['status'] != 'Approved')
                                TextButton.icon(
                                  onPressed: () => _approveOwner(index),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Approve'),
                                ),
                              if (owner['status'] != 'Suspended')
                                TextButton.icon(
                                  onPressed: () => _suspendOwner(index),
                                  icon: const Icon(Icons.block, size: 18),
                                  label: const Text('Suspend'),
                                ),
                            ],
                          )
                        ]),
                  ),
                );
              },
            ),
    );
  }
}
