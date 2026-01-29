import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../Owner_Panel/edit_court_screen.dart';

class CourtDetails extends StatelessWidget {
  final Map<String, dynamic> court;

  const CourtDetails({
    super.key,
    required this.court,
  });

  // ================= IMAGES =================

  Widget _buildImage() {
    final images = (court['images'] as List?)?.cast<String>() ?? [];

    if (images.isEmpty) {
      return _imagePlaceholder();
    }

    final image = images.first;

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    if (image.startsWith('/')) {
      return Image.file(
        File(image),
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 48),
      ),
    );
  }

  // ================= MAP =================

  Future<void> _openInMaps(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final facilities = (court['facilities'] as List?)?.cast<String>() ?? [];
    final mapUrl = court['mapUrl'];
    final addressText = court['location'];

    /// 🔥 MULTI-SPORT SUPPORT
    final List<Map<String, dynamic>> sports =
        (court['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Court Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= COURT DETAILS =================
            const Text(
              'Court Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoLine('Court Name', court['name']),
                    _infoLine('Description', court['description']),
                    _infoLine('Address', addressText),
                    if (mapUrl != null && mapUrl.toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: TextButton.icon(
                          onPressed: () => _openInMaps(context, mapUrl),
                          icon: const Icon(Icons.map),
                          label: const Text('Open in Google Maps'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(child: _infoLine('City', court['city'])),
                        const SizedBox(width: 12),
                        Expanded(child: _infoLine('State', court['state'])),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _infoLine('Zip Code', court['zipCode']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoLine(
                            'Price / hour',
                            '${court['pricePerHour']} PKR',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SPORTS =================
            const Text(
              'Sports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            sports.isEmpty
                ? const Text(
                    'No sports assigned',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sports.map((s) {
                      return Chip(
                        label: Text(s['name']),
                        backgroundColor: AppColors.primaryColor,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),

            // ================= IMAGES =================
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),

            const SizedBox(height: 24),

            // ================= FACILITIES =================
            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            facilities.isEmpty
                ? const Text(
                    'No facilities added',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: facilities.map((f) {
                      return Chip(
                        label: Text(f),
                        backgroundColor:
                            AppColors.primaryColor.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 36),

            // ================= ACTION =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCourtScreen(court: court),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Edit Court',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO LINE =================

  Widget _infoLine(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value?.toString() ?? 'N/A',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
