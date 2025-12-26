import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // ================= FETCH =================
  Future<void> _fetchNotifications() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final res = await ApiService.get('/notifications', token);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data']['notifications'] as List;

        setState(() {
          notifications = data.map<Map<String, dynamic>>((n) {
            return {
              'id': n['id'],
              'title': n['title'] ?? 'Notification',
              'message': n['message'] ?? '',
              'isRead': n['isRead'] ?? false,
              'createdAt': n['createdAt'],
              'type': n['type'] ?? 'GENERAL',
            };
          }).toList();

          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Notification fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= MARK ONE =================
  Future<void> _markAsRead(String id) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.post('/notifications/$id/read', token, {});
    await _fetchNotifications();
  }

  // ================= MARK ALL =================
  Future<void> _markAllRead() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    await ApiService.post('/notifications/read-all', token, {});
    await _fetchNotifications();
  }

  // ================= GROUP BY DATE =================
  Map<String, List<Map<String, dynamic>>> _grouped() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();

    for (final n in notifications) {
      final date = DateTime.parse(n['createdAt']);
      String key;

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

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(n);
    }

    return grouped;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _grouped();

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty ? null : _markAllRead,
            child: const Text("Mark All Read",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text("No notifications yet!",
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: groupedNotifications.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.headingBlue)),
                        const SizedBox(height: 6),
                        ...entry.value.map(_notificationTile).toList(),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  // ================= TILE =================
  Widget _notificationTile(Map<String, dynamic> n) {
    final isUnread = !(n['isRead'] as bool);

    return GestureDetector(
      onTap: isUnread ? () => _markAsRead(n['id']) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Stack(
            children: [
              Icon(Icons.notifications,
                  size: 30,
                  color: isUnread ? AppColors.primaryColor : Colors.grey),
              if (isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                  ),
                )
            ],
          ),
          title: Text(
            n['title'],
            style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
          ),
          subtitle: Text(n['message']),
          trailing: isUnread
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("NEW",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                )
              : null,
        ),
      ),
    );
  }
}
