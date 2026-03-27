import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../services/image_upload_service.dart';
import 'my_bookings_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String courtId;
  final String courtName;
  final double pricePerHour;
  final String selectedSport;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> selectedSlots;
  final bool findOpponent;
  final Function(int)? onBookingComplete;

  const PaymentScreen({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.pricePerHour,
    required this.selectedSport,
    required this.selectedDate,
    required this.selectedSlots,
    required this.findOpponent,
    this.onBookingComplete,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _paymentImage;
  bool _isSubmitting = false;

  late double totalPrice;
  late double advanceAmount;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    double total = 0;
    for (var slot in widget.selectedSlots) {
      final start = slot['startTime'].toString().split(':');
      final end = slot['endTime'].toString().split(':');
      final startHr = int.parse(start[0]) + (int.parse(start[1]) / 60);
      final endHr = int.parse(end[0]) + (int.parse(end[1]) / 60);
      total += widget.pricePerHour * (endHr - startHr);
    }
    totalPrice = total;
    advanceAmount = total * 0.20;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _paymentImage = File(pickedFile.path));
    }
  }

  Future<void> _submitVerification() async {
    if (_paymentImage == null) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception("Unauthorized");

      // 1. Upload to Cloudinary
      final imageUrl = await ImageUploadService.uploadToCloudinary(_paymentImage!);
      if (imageUrl == null) {
        throw Exception("Failed to upload payment screenshot");
      }

      final dateString = widget.selectedDate.toIso8601String().split('T').first;

      // 2. Submit booking for all slots
      for (final slot in widget.selectedSlots) {
        final res = await ApiService.post(
          '/player/bookings',
          token,
          {
            'courtId': widget.courtId,
            'sport': widget.selectedSport,
            'date': dateString,
            'startTime': slot['startTime'],
            'endTime': slot['endTime'],
            'findOpponent': widget.findOpponent,
            'paymentScreenshot': imageUrl,
            'advanceAmountPaid': advanceAmount,
            'totalPrice': totalPrice,
          },
        );

        if (res.statusCode != 200 && res.statusCode != 201) {
          final body = jsonDecode(res.body);
          throw Exception(body['message'] ?? 'Booking failed');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request submitted for approval'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
        (route) => route.isFirst,
      );

      widget.onBookingComplete?.call(widget.findOpponent ? 3 : 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Payment Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.courtName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Booking Price:", style: TextStyle(color: Colors.grey)),
                      Text("Rs. ${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Advance Payment (20%):",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Rs. ${advanceAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    "To request this booking, transfer 20% of the total amount (Rs. ${advanceAmount.toStringAsFixed(0)}) to:",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "03001234567", // Simulated placeholder account
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  const Text("JazzCash / EasyPaisa", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Upload Payment Screenshot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _paymentImage == null ? Colors.grey.shade300 : AppColors.primaryColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _paymentImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_paymentImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Tap to upload screenshot", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (_paymentImage == null || _isSubmitting) ? null : _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit for Approval",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
