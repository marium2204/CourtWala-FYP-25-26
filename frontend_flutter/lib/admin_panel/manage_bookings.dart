import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<Map<String, dynamic>> bookings = [
    {
      'player': 'Ali Ahmed',
      'court': 'Elite Badminton Arena',
      'date': '2025-11-16',
      'time': '10:00 AM',
      'status': 'Pending',
    },
    {
      'player': 'Sara Khan',
      'court': 'City Tennis Court',
      'date': '2025-11-16',
      'time': '2:00 PM',
      'status': 'Confirmed',
    },
    {
      'player': 'Omar Riaz',
      'court': 'Green Valley Sports Center',
      'date': '2025-11-17',
      'time': '11:30 AM',
      'status': 'Cancelled',
    },
    {
      'player': 'Fatima Noor',
      'court': 'Sunrise Indoor Court',
      'date': '2025-11-18',
      'time': '4:00 PM',
      'status': 'Pending',
    },
  ];

  void _confirmBooking(int index) {
    setState(() {
      bookings[index]['status'] = 'Confirmed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Booking for ${bookings[index]['player']} confirmed')),
    );
  }

  void _cancelBooking(int index) {
    setState(() {
      bookings[index]['status'] = 'Cancelled';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Booking for ${bookings[index]['player']} cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Bookings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                Color statusColor;
                if (booking['status'] == 'Confirmed') {
                  statusColor = Colors.green;
                } else if (booking['status'] == 'Pending') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.red;
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
                        Text('${booking['player']} - ${booking['court']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.headingBlue)),
                        const SizedBox(height: 4),
                        Text('${booking['date']} • ${booking['time']}',
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
                              child: Text(booking['status'],
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (booking['status'] != 'Confirmed')
                                  TextButton.icon(
                                    onPressed: () => _confirmBooking(index),
                                    icon: const Icon(Icons.check_circle,
                                        size: 18),
                                    label: const Text('Confirm'),
                                  ),
                                if (booking['status'] != 'Cancelled')
                                  TextButton.icon(
                                    onPressed: () => _cancelBooking(index),
                                    icon: const Icon(Icons.cancel, size: 18),
                                    label: const Text('Cancel'),
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
