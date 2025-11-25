import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ManageCourtsScreen extends StatefulWidget {
  const ManageCourtsScreen({super.key});

  @override
  State<ManageCourtsScreen> createState() => _ManageCourtsScreenState();
}

class _ManageCourtsScreenState extends State<ManageCourtsScreen> {
  List<Map<String, dynamic>> courts = [
    {
      'name': 'Elite Badminton Arena',
      'description': 'Indoor badminton court with modern facilities.',
      'address': '123 Downtown St.',
      'city': 'Downtown',
      'state': 'CA',
      'zipCode': '90001',
      'sport': 'Badminton',
      'pricePerHour': 30,
      'amenities': ['Shower', 'Parking', 'Locker'],
      'images': ['https://via.placeholder.com/100'],
      'status': 'PENDING_APPROVAL',
      'ownerId': 'Owner A',
    },
    {
      'name': 'City Tennis Court',
      'description': 'Outdoor tennis court open to all members.',
      'address': '456 Uptown Ave.',
      'city': 'Uptown',
      'state': 'CA',
      'zipCode': '90002',
      'sport': 'Tennis',
      'pricePerHour': 25,
      'amenities': ['Parking'],
      'images': ['https://via.placeholder.com/100'],
      'status': 'ACTIVE',
      'ownerId': 'Owner B',
    },
  ];

  void _updateCourtStatus(int index) {
    final court = courts[index];
    String selectedStatus = court['status'];
    TextEditingController reasonController =
        TextEditingController(text: court['reason'] ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Update Court Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED')),
                  DropdownMenuItem(
                      value: 'PENDING_APPROVAL',
                      child: Text('PENDING_APPROVAL')),
                ],
                onChanged: (value) {
                  if (value != null) selectedStatus = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
              onPressed: () {
                setState(() {
                  courts[index]['status'] = selectedStatus;
                  courts[index]['reason'] = reasonController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${courts[index]['name']} status updated to $selectedStatus')));
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourt(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Court'),
          content:
              Text('Are you sure you want to delete ${courts[index]['name']}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                setState(() {
                  courts.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Court deleted successfully')));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Courts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: courts.isEmpty
          ? const Center(child: Text('No courts available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final court = courts[index];
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
                              child: Text(court['name'][0],
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(court['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.headingBlue)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${court['sport']} | \$${court['pricePerHour']}/hr',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${court['address']}, ${court['city']}, ${court['state']} - ${court['zipCode']}',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: court['status'] == 'ACTIVE'
                                      ? Colors.green[100]
                                      : court['status'] == 'INACTIVE'
                                          ? Colors.orange[100]
                                          : court['status'] == 'REJECTED'
                                              ? Colors.red[100]
                                              : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(court['status'],
                                  style: TextStyle(
                                      color: court['status'] == 'ACTIVE'
                                          ? Colors.green[800]
                                          : court['status'] == 'INACTIVE'
                                              ? Colors.orange[800]
                                              : court['status'] == 'REJECTED'
                                                  ? Colors.red[800]
                                                  : Colors.grey[800],
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
                              onPressed: () => _updateCourtStatus(index),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Update Status'),
                            ),
                            TextButton.icon(
                              onPressed: () => _deleteCourt(index),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent),
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
