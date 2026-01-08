import 'dart:io';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../Owner_Panel/edit_court_screen.dart';

class CourtDetails extends StatelessWidget {
  final Map<String, dynamic> court;

  const CourtDetails({
    super.key,
    required this.court,
  });

  Widget _buildImage() {
    final image = court['image'];

    if (image == null || image.toString().isEmpty) {
      return _imagePlaceholder();
    }

    if (image is String && image.startsWith('/')) {
      return Image.file(
        File(image),
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      );
    }

    if (image is String && image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
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

  @override
  Widget build(BuildContext context) {
    final facilities = (court['facilities'] as List?)?.cast<String>() ?? [];

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
            // ================= SECTION: COURT DETAILS =================
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
                    _infoLine('Address', court['location']),
                    Row(
                      children: [
                        Expanded(
                          child: _infoLine('City', court['city']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoLine('State', court['state']),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _infoLine('Zip Code', court['zip']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoLine(
                            'Price / hour',
                            '${court['price']} PKR',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= SECTION: SPORT =================
            const Text(
              'Sport',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: [
                Chip(
                  label: Text(court['sport'] ?? ''),
                  backgroundColor: AppColors.primaryColor,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= SECTION: IMAGES =================
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

            // ================= SECTION: FACILITIES =================
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
          Text(
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
