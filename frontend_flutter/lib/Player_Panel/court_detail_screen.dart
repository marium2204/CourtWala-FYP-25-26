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
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  // ================= COURT IMAGES (CLOUDINARY SAFE) =================
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

            if (img is! String || img.isEmpty) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 40),
              );
            }

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

    final String description = court!['description'] ?? '';
    final String addressText = court!['location'] ?? '';
    final String? mapUrl = court!['mapUrl'];

    final List<Map<String, dynamic>> sports =
        (court!['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final List images = court!['images'] is List ? court!['images'] : [];

    final String? firstImage =
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
        elevation: 0,
      ),
      body: Column(
        children: [
          // ================= COURT CARD =================
          Container(
            margin: const EdgeInsets.all(16),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15),
                  ),

                const SizedBox(height: 14),
                _detailRow(Icons.location_on, addressText),

                if (mapUrl != null && mapUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: TextButton.icon(
                      onPressed: () => _openInMaps(mapUrl),
                      icon: const Icon(Icons.map),
                      label: const Text('Open in Google Maps'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),

                if (sports.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Sports Available',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sports.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Price per hour",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
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

          const Spacer(),

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
                        sport: sports.map((s) => s['name']).join(', '),
                        price: court!['pricePerHour'].toString(),
                        image: firstImage, // ✅ CLOUDINARY URL OR NULL
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
