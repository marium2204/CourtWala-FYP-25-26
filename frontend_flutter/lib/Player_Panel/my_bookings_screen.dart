// lib/Player_Panel/my_bookings_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Map<String, String>> bookings = [
    {
      'court': 'Elite Badminton Arena',
      'date': '05 Nov 2025',
      'time': '03:00 PM - 04:00 PM',
      'status': 'Confirmed'
    },
    {
      'court': 'Champions Cricket Ground',
      'date': '08 Nov 2025',
      'time': '06:00 PM - 09:00 PM',
      'status': 'Pending'
    },
  ];

  void _cancelBooking(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                bookings.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking canceled.")),
              );
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                "No bookings yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final b = bookings[i];
                final bool isConfirmed = b['status'] == 'Confirmed';

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Court name
                        Text(
                          b['court']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.headingBlue),
                        ),
                        const SizedBox(height: 6),
                        // Date & time row
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              b['date']!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time,
                                size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              b['time']!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Status and cancel button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                b['status']!,
                                style: TextStyle(
                                    color: isConfirmed
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Cancel button
                            ElevatedButton.icon(
                              onPressed: () => _cancelBooking(i),
                              icon: const Icon(
                                Icons.cancel,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Cancel Booking",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 196, 70, 31),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
