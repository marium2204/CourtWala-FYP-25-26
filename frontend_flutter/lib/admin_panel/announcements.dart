import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class AnnouncementItem {
  final String id;
  final String title;
  final String message;
  final List<String> targetAudience;
  final DateTime? scheduledAt;
  final bool isActive;
  final DateTime? createdAt;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.targetAudience,
    this.scheduledAt,
    required this.isActive,
    this.createdAt,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      targetAudience: (json['targetAudience'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class AnnouncementsScreen extends StatefulWidget {
  final String adminToken;

  const AnnouncementsScreen({super.key, required this.adminToken});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<AnnouncementItem> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final res = await ApiService.get(
        '/admin/announcements',
        widget.adminToken,
      );

      final decoded = jsonDecode(res.body);

      if (res.statusCode != 200 || decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to load announcements');
      }

      final List list = decoded['data']?['announcements'] ?? [];

      setState(() {
        announcements = list.map((e) => AnnouncementItem.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Announcements error: $e');
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _openCreateDialog() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    List<String> audience = [];
    DateTime? scheduledAt;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create Announcement'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['PLAYER', 'COURT_OWNER'].map((role) {
                      return FilterChip(
                        label: Text(role),
                        selected: audience.contains(role),
                        onSelected: (v) {
                          setDialogState(() {
                            v ? audience.add(role) : audience.remove(role);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() {
                            scheduledAt = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text(
                      scheduledAt == null
                          ? 'Pick Schedule (Optional)'
                          : 'Scheduled: ${scheduledAt!.toLocal()}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: () async {
                  if (titleCtrl.text.isEmpty ||
                      messageCtrl.text.isEmpty ||
                      audience.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title, message & audience are required'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  await ApiService.post(
                    '/admin/announcements',
                    widget.adminToken,
                    {
                      'title': titleCtrl.text,
                      'message': messageCtrl.text,
                      'targetAudience': audience,
                      if (scheduledAt != null)
                        'scheduledAt': scheduledAt!.toIso8601String(),
                    },
                  );

                  _fetchAnnouncements();
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title:
            const Text('Announcements', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openCreateDialog),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : announcements.isEmpty
              ? const Center(child: Text('No announcements found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final a = announcements[i];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headingBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(a.message),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: a.targetAudience
                                  .map(
                                    (e) => Chip(
                                      label: Text(e,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            if (a.createdAt != null)
                              Text(
                                'Created: ${a.createdAt!.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              'Scheduled: ${a.scheduledAt != null ? a.scheduledAt!.toLocal() : 'N/A'}',
                              style: const TextStyle(fontSize: 12),
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
