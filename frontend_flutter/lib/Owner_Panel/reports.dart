import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';
import '../theme/colors.dart';
import '../authentication_screens/splash_screen.dart';

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
        MaterialPageRoute(builder: (_) => const SplashScreen()),
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
        '/player/reports', // ✅ ONLY VALID ROUTE
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
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Report to Admin',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== INFO =====
              Text(
                'Reporting ${widget.reportType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please clearly describe the issue. Admin will review and take action.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ===== MESSAGE =====
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Message is required'
                    : null,
              ),

              const Spacer(),

              // ===== SUBMIT =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 18,
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
