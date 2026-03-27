import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../authentication_screens/auth_gate.dart';
import 'booking_page.dart';

class CourtDetailScreen extends StatefulWidget {
  final String courtId;

  const CourtDetailScreen({super.key, required this.courtId});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? court;

  @override
  void initState() {
    super.initState();
    _fetchCourt();
  }

  Future<void> _fetchCourt() async {
    final token = await TokenService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
      return;
    }

    try {
      final res = await ApiService.get('/courts/${widget.courtId}', token);
      if (res.statusCode == 200) {
        setState(() {
          court = jsonDecode(res.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      debugPrint('Court fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _openInMaps(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _courtImages(List images) {
    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (_, index) {
            final img = images[index];
            return Image.network(
              img,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (court == null) {
      return const Scaffold(
        body: Center(child: Text('Court not found')),
      );
    }

    final description = court!['description'] ?? '';
    final addressText = court!['location'] ?? '';
    final mapUrl = court!['mapUrl'];
    final List<String> amenities =
        (court!['amenities'] as List?)?.cast<String>() ?? [];

    final sports =
        (court!['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final images = court!['images'] is List ? court!['images'] : [];
    final firstImage =
        images.isNotEmpty && images.first is String ? images.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Court Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// ✅ FIXED LAYOUT
      body: Column(
        children: [
          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _courtImages(images),
                    const SizedBox(height: 16),
                    Text(
                      court!['name'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(description),
                    ],
                    const SizedBox(height: 14),
                    _detailRow(Icons.location_on, addressText),
                    if (mapUrl != null && mapUrl.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _openInMaps(mapUrl),
                        icon: const Icon(Icons.map),
                        label: const Text('Open in Google Maps'),
                      ),
                    if (sports.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Sports Available',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sports.map((s) {
                          return Chip(
                            label: Text(s['name']),
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (amenities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Amenities',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: amenities.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              a,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Price per hour",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            "PKR ${court!['pricePerHour']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FIXED BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        courtid: court!['id'],
                        courtName: court!['name'],
                        description: description,
                        location: addressText,
                        sports: sports.map((s) => s['name'].toString()).toList(),
                        price: court!['pricePerHour'].toString(),
                        image: firstImage,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Book This Court",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
