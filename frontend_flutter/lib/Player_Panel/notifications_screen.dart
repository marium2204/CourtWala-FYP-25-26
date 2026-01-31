import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // ================= TIME =================
  String _formatTime(String isoDate) {
    final localDate = DateTime.parse(isoDate).toLocal();
    return DateFormat('hh:mm a').format(localDate);
  }

  // ================= HEADING =================
  String _notificationHeading(String type) {
    switch (type) {
      case 'BOOKING_REQUESTED':
      case 'BOOKING_APPROVED':
      case 'BOOKING_REJECTED':
      case 'BOOKING_CANCELLED':
        return 'BOOKING UPDATE';
      case 'MATCH_REQUEST':
      case 'MATCH_ACCEPTED':
      case 'MATCH_REJECTED':
        return 'MATCH UPDATE';
      case 'COURT_APPROVED':
      case 'COURT_REJECTED':
        return 'COURT STATUS';
      case 'OWNER_APPROVED':
      case 'OWNER_REJECTED':
        return 'OWNER STATUS';
      case 'ADMIN_ANNOUNCEMENT':
        return 'ADMIN ANNOUNCEMENT';
      case 'TOURNAMENT_JOINED':
        return 'TOURNAMENT';
      case 'REPORT_RESOLVED':
        return 'REPORT UPDATE';
      default:
        return 'NOTIFICATION';
    }
  }

  // ================= GROUP BY DATE =================
  Map<String, List<Map<String, dynamic>>> _grouped() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();

    for (final n in notifications) {
      final date = DateTime.parse(n['createdAt']).toLocal();
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
        key = "${date.day}/${date.month}/${date.year}";
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
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty ? null : _markAllRead,
            child: const Text(
              "Mark all read",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: groupedNotifications.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map(_notificationTile),
                        const SizedBox(height: 18),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  // ================= TILE =================
  Widget _notificationTile(Map<String, dynamic> n) {
    final bool isUnread = !(n['isRead'] as bool);

    final Color bgColor = isUnread
        ? AppColors.primaryColor.withOpacity(0.08)
        : Colors.grey.shade200;

    final Color textColor = isUnread ? Colors.black : Colors.grey.shade700;
    final Color subTextColor = isUnread ? Colors.black87 : Colors.grey;
    final Color iconColor = isUnread ? AppColors.primaryColor : Colors.grey;

    return GestureDetector(
      onTap: isUnread ? () => _markAsRead(n['id']) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 30,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _notificationHeading(n['type']),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isUnread ? AppColors.primaryColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(n['createdAt']),
                        style: TextStyle(
                          fontSize: 11,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['message'],
                    style: TextStyle(color: subTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
