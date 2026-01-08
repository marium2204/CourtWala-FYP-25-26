import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class ReportItem {
  final String id;
  final String type;
  final String message;
  String status;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedCourtId;
  final DateTime createdAt;

  ReportItem({
    required this.id,
    required this.type,
    required this.message,
    required this.status,
    required this.reporterId,
    this.reportedUserId,
    this.reportedCourtId,
    required this.createdAt,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      status: json['status'],
      reporterId: json['reporterId'],
      reportedUserId: json['reportedUserId'],
      reportedCourtId: json['reportedCourtId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  final String adminToken;

  const ReportsScreen({super.key, required this.adminToken});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportItem> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final res = await ApiService.get(
        '/admin/reports',
        widget.adminToken,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List list = decoded['data']['reports'];

        setState(() {
          reports = list.map((e) => ReportItem.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Fetch reports error: $e');
      setState(() => isLoading = false);
    }
  }

  void _resolveReport(ReportItem report) {
    final actionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Resolve Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actionCtrl,
              decoration: _dialogInput('Action taken *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              decoration: _dialogInput('Notes (optional)'),
            ),
          ],
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
              if (actionCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action is required')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final res = await ApiService.post(
                  '/admin/reports/${report.id}/resolve',
                  widget.adminToken,
                  {
                    'action': actionCtrl.text,
                    'notes': notesCtrl.text,
                  },
                );

                if (res.statusCode == 200) {
                  setState(() => report.status = 'RESOLVED');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report resolved')),
                  );
                }
              } catch (e) {
                debugPrint('Resolve report error: $e');
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInput(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'DISMISSED':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reports & Complaints',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? Center(
                  child: Text(
                    'No reports found',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final r = reports[i];

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
                          /// =========================
                          /// Title
                          /// =========================
                          Text(
                            '${r.type} Report',
                            style: AppTextStyles.title,
                          ),

                          const SizedBox(height: 6),
                          Text(
                            r.message,
                            style: AppTextStyles.subtitle,
                          ),

                          const SizedBox(height: 12),

                          /// =========================
                          /// Meta
                          /// =========================
                          if (r.reportedUserId != null)
                            Text(
                              'User ID: ${r.reportedUserId}',
                              style:
                                  AppTextStyles.subtitle.copyWith(fontSize: 13),
                            ),
                          if (r.reportedCourtId != null)
                            Text(
                              'Court ID: ${r.reportedCourtId}',
                              style:
                                  AppTextStyles.subtitle.copyWith(fontSize: 13),
                            ),
                          Text(
                            'Reporter: ${r.reporterId}',
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 13),
                          ),
                          Text(
                            'Created: ${r.createdAt.toLocal().toString().split('.')[0]}',
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 13),
                          ),

                          const SizedBox(height: 14),

                          /// =========================
                          /// Status & Action
                          /// =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(r.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  r.status,
                                  style: TextStyle(
                                    color: _statusColor(r.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (r.status == 'PENDING')
                                TextButton.icon(
                                  onPressed: () => _resolveReport(r),
                                  icon: const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: AppColors.primaryColor,
                                  ),
                                  label: const Text(
                                    'Resolve',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
