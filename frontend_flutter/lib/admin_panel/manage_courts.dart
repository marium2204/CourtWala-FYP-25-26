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
      'location': 'Downtown',
      'status': 'Enabled',
      'bookings': 15,
    },
    {
      'name': 'City Tennis Court',
      'location': 'Uptown',
      'status': 'Disabled',
      'bookings': 5,
    },
    {
      'name': 'Green Valley Sports Center',
      'location': 'Suburbs',
      'status': 'Enabled',
      'bookings': 8,
    },
    {
      'name': 'Sunrise Indoor Court',
      'location': 'City Center',
      'status': 'Enabled',
      'bookings': 3,
    },
  ];

  void _enableCourt(int index) {
    setState(() {
      courts[index]['status'] = 'Enabled';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${courts[index]['name']} enabled')),
    );
  }

  void _disableCourt(int index) {
    setState(() {
      courts[index]['status'] = 'Disabled';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${courts[index]['name']} disabled')),
    );
  }

  void _viewBookings(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('${courts[index]['name']} - Bookings'),
          content:
              Text('This court has ${courts[index]['bookings']} booking(s).'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
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
                                  Text(court['location'],
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: court['status'] == 'Enabled'
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(court['status'],
                                  style: TextStyle(
                                      color: court['status'] == 'Enabled'
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
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: const Text('View Bookings'),
                            ),
                            if (court['status'] != 'Enabled')
                              TextButton.icon(
                                onPressed: () => _enableCourt(index),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Enable'),
                              ),
                            if (court['status'] != 'Disabled')
                              TextButton.icon(
                                onPressed: () => _disableCourt(index),
                                icon: const Icon(Icons.block, size: 18),
                                label: const Text('Disable'),
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
