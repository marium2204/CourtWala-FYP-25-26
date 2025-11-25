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
      'id': 'R001',
      'type': 'USER',
      'message': 'Player was aggressive on court.',
      'reportedUserId': 'U123',
      'reportedCourtId': null,
      'status': 'PENDING',
      'reporterId': 'U456',
      'createdAt': '2025-11-15',
    },
    {
      'id': 'R002',
      'type': 'COURT',
      'message': 'Court lighting not working.',
      'reportedUserId': null,
      'reportedCourtId': 'C789',
      'status': 'RESOLVED',
      'reporterId': 'U321',
      'createdAt': '2025-11-14',
    },
    {
      'id': 'R003',
      'type': 'BOOKING',
      'message': 'Double booking occurred.',
      'reportedUserId': 'U987',
      'reportedCourtId': 'C654',
      'status': 'PENDING',
      'reporterId': 'U321',
      'createdAt': '2025-11-13',
    },
  ];

  void _resolveReport(int index) {
    final report = reports[index];
    TextEditingController actionController = TextEditingController();
    TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Resolve Report: ${report['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actionController,
                decoration: const InputDecoration(
                  labelText: 'Action (e.g., Warning issued, Block user)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
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
                  reports[index]['status'] = 'RESOLVED';
                  reports[index]['action'] = actionController.text;
                  reports[index]['notes'] = notesController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Report ${report['id']} marked as resolved')));
              },
              child: const Text('Resolve'),
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
        title: const Text('Reports & Complaints',
            style: TextStyle(color: Colors.white)),
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
                Color statusColor = report['status'] == 'RESOLVED'
                    ? Colors.green
                    : report['status'] == 'DISMISSED'
                        ? Colors.grey
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
                        Text('${report['type']} Report (${report['id']})',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.headingBlue)),
                        const SizedBox(height: 4),
                        Text('Message: ${report['message']}',
                            style: const TextStyle(color: Colors.grey)),
                        if (report['reportedUserId'] != null)
                          Text('Reported User ID: ${report['reportedUserId']}',
                              style: const TextStyle(color: Colors.grey)),
                        if (report['reportedCourtId'] != null)
                          Text(
                              'Reported Court ID: ${report['reportedCourtId']}',
                              style: const TextStyle(color: Colors.grey)),
                        Text('Reporter ID: ${report['reporterId']}',
                            style: const TextStyle(color: Colors.grey)),
                        Text('Created At: ${report['createdAt']}',
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
                                if (report['status'] == 'PENDING')
                                  TextButton.icon(
                                    onPressed: () => _resolveReport(index),
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
