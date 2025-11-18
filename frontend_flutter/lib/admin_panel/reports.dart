import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> reports = [
    {
      'user': 'Ali Ahmed',
      'type': 'Court Issue',
      'details': 'Court lights not working properly.',
      'date': '2025-11-15',
      'status': 'Pending',
    },
    {
      'user': 'Sara Khan',
      'type': 'Booking Issue',
      'details': 'Double booking occurred for my slot.',
      'date': '2025-11-14',
      'status': 'Resolved',
    },
    {
      'user': 'Omar Riaz',
      'type': 'Player Misconduct',
      'details': 'Other player was aggressive and unsafe.',
      'date': '2025-11-13',
      'status': 'Pending',
    },
  ];

  void _markResolved(int index) {
    setState(() {
      reports[index]['status'] = 'Resolved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Report by ${reports[index]['user']} marked as resolved')),
    );
  }

  void _viewDetails(int index) {
    showDialog(
      context: context,
      builder: (_) {
        final report = reports[index];
        return AlertDialog(
          title: Text('${report['type']} by ${report['user']}'),
          content: Text(report['details']),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
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
          'Reports & Complaints',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: reports.isEmpty
          ? const Center(child: Text('No reports available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = reports[index];
                Color statusColor = report['status'] == 'Resolved'
                    ? Colors.green
                    : Colors.orange;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${report['type']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.headingBlue)),
                        const SizedBox(height: 4),
                        Text('Reported by: ${report['user']}',
                            style: const TextStyle(color: Colors.grey)),
                        Text('Date: ${report['date']}',
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
                              child: Text(report['status'],
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _viewDetails(index),
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text('View'),
                                ),
                                if (report['status'] != 'Resolved')
                                  TextButton.icon(
                                    onPressed: () => _markResolved(index),
                                    icon: const Icon(Icons.check_circle,
                                        size: 18),
                                    label: const Text('Resolve'),
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
    );
  }
}
