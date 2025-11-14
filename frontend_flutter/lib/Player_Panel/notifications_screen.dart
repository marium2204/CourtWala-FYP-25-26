// lib/Player_Panel/notifications_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking at Elite Badminton Arena is confirmed',
      'isNew': true,
      'date': DateTime.now(),
      'type': 'Booking',
    },
    {
      'title': 'New Match Invite',
      'message': 'You have been invited to play on Saturday',
      'isNew': true,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Match',
    },
    {
      'title': 'Challenge Completed',
      'message': 'You have successfully completed your challenge!',
      'isNew': false,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'Challenge',
    },
  ];

  // Delete notification
  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Notification deleted")));
  }

  // Mark as read/unread
  void _toggleRead(int index) {
    setState(() {
      notifications[index]['isNew'] = !(notifications[index]['isNew'] as bool);
    });
  }

  // Group notifications by day
  Map<String, List<Map<String, dynamic>>> _groupNotifications() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var n in notifications) {
      DateTime date = n['date'] as DateTime;
      String key;
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        key = "Today";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        key = "Yesterday";
      } else {
        key = "${date.day}-${date.month}-${date.year}";
      }

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in notifications) n['isNew'] = false;
              });
            },
            child: const Text(
              "Mark All Read",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: groupedNotifications.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...entry.value.asMap().entries.map((pair) {
                      int index = notifications.indexOf(pair.value);
                      final n = pair.value;
                      final isNew = n['isNew'] as bool? ?? false;
                      return Dismissible(
                        key: Key(n['title'] + index.toString()),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.mark_email_read,
                              color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            _deleteNotification(index);
                          } else {
                            _toggleRead(index);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isNew
                                ? Colors.blue.withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: Stack(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: isNew
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                  size: 32,
                                ),
                                if (isNew)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              n['title'],
                              style: TextStyle(
                                fontWeight:
                                    isNew ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              n['message'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: isNew
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  )
                                : null,
                            onTap: () => _toggleRead(index),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
