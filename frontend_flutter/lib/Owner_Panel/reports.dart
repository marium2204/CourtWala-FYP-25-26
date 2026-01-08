import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';
import '../authentication_screens/auth_gate.dart';

class ReportToAdminScreen extends StatefulWidget {
  /// One of: USER, COURT, BOOKING
  final String reportType;

  /// Only ONE of these should be non-null
  final String? reportedUserId;
  final String? reportedCourtId;
  final String? reportedBookingId;

  const ReportToAdminScreen({
    super.key,
    required this.reportType,
    this.reportedUserId,
    this.reportedCourtId,
    this.reportedBookingId,
  });

  @override
  State<ReportToAdminScreen> createState() => _ReportToAdminScreenState();
}

class _ReportToAdminScreenState extends State<ReportToAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  // ================= SUBMIT REPORT =================
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await TokenService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final Map<String, dynamic> payload = {
        'type': widget.reportType,
        'message': _messageCtrl.text.trim(),
      };

      if (widget.reportedUserId != null) {
        payload['reportedUserId'] = widget.reportedUserId;
      }

      if (widget.reportedCourtId != null) {
        payload['reportedCourtId'] = widget.reportedCourtId;
      }

      if (widget.reportedBookingId != null) {
        payload['reportedBookingId'] = widget.reportedBookingId;
      }

      final res = await ApiService.post(
        '/player/reports',
        token,
        payload,
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 201 && body['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(body['message'] ?? 'Failed to submit report');
      }
    } catch (e) {
      debugPrint('Report submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Report to Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= CONTEXT CARD =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporting ${widget.reportType}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please clearly describe the issue. Our admin team will review and take appropriate action.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= MESSAGE FIELD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _messageCtrl,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: const Color(0xFFF2F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Message is required'
                      : null,
                ),
              ),

              const Spacer(),

              // ================= SUBMIT BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
