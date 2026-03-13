import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
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
      final res =
          await ApiService.get('/admin/announcements', widget.adminToken);

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

  /* ================= CREATE DIALOG ================= */

  void _openCreateDialog() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    List<String> audience = [];
    DateTime? scheduledAt;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white, // ✅ NO PURPLE
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// =========================
                      /// Header
                      /// =========================
                      Text(
                        'Create Announcement',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Send an announcement to selected users',
                        style: AppTextStyles.subtitle,
                      ),

                      const SizedBox(height: 20),

                      /// =========================
                      /// Title
                      /// =========================
                      Text('Title', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleCtrl,
                        decoration: _dialogInput('Announcement title'),
                      ),

                      const SizedBox(height: 14),

                      /// =========================
                      /// Message
                      /// =========================
                      Text('Message', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: messageCtrl,
                        maxLines: 4,
                        decoration: _dialogInput('Write your message'),
                      ),

                      const SizedBox(height: 18),

                      /// =========================
                      /// Audience
                      /// =========================
                      Text('Target Audience', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: ['PLAYER', 'COURT_OWNER'].map((role) {
                          final selected = audience.contains(role);
                          return FilterChip(
                            label: Text(
                              role,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primaryColor
                                    : AppColors.textPrimary,
                              ),
                            ),
                            selected: selected,
                            selectedColor:
                                AppColors.primaryColor.withOpacity(0.15),
                            backgroundColor: AppColors.backgroundColor,
                            checkmarkColor: AppColors.primaryColor,
                            onSelected: (v) {
                              setDialogState(() {
                                v ? audience.add(role) : audience.remove(role);
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      /// =========================
                      /// Schedule
                      /// =========================
                      Text('Schedule (Optional)', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
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
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Text(
                            scheduledAt == null
                                ? 'Pick date & time'
                                : scheduledAt!
                                    .toLocal()
                                    .toString()
                                    .split('.')[0],
                            style: AppTextStyles.subtitle,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      /// =========================
                      /// Actions
                      /// =========================
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColors.primaryColor, // 🔵 text color
                                side: BorderSide(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.4),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentColor, // 🟡
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                if (titleCtrl.text.isEmpty ||
                                    messageCtrl.text.isEmpty ||
                                    audience.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Title, message & target audience are required'),
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
                                      'scheduledAt':
                                          scheduledAt!.toIso8601String(),
                                  },
                                );

                                _fetchAnnouncements();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Announcement created successfully"),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                              child: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _dialogInput(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
              ? Center(
                  child: Text(
                    'No announcements found',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final a = announcements[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: AppTextStyles.heading),
                          const SizedBox(height: 6),
                          Text(a.message, style: AppTextStyles.subtitle),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: a.targetAudience.map((e) {
                              return Chip(
                                label: Text(
                                  e,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: AppColors.primaryColor,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          if (a.createdAt != null)
                            Text(
                              'Created: ${a.createdAt!.toLocal().toString().split('.')[0]}',
                              style:
                                  AppTextStyles.subtitle.copyWith(fontSize: 12),
                            ),
                          Text(
                            'Scheduled: ${a.scheduledAt != null ? a.scheduledAt!.toLocal() : 'N/A'}',
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
