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

  // ================= IMAGE HANDLER =================
  Widget _buildCourtImage() {
    final image = court['image'];

    if (image == null || image.toString().isEmpty) {
      return _imageFallback();
    }

    if (image is String && image.startsWith('/')) {
      return Image.file(
        File(image),
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      );
    }

    if (image is String && image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      height: 240,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilities = (court['facilities'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(
          court['name'] ?? 'Court Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= IMAGE =================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: _buildCourtImage(),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= NAME =================
                  Text(
                    court['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingBlue,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.sports_tennis,
                          size: 20, color: AppColors.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        court['sport'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= INFO CARD =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.location_on,
                          court['location'] ?? 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.attach_money,
                          '${court['price'] ?? 0} / hr',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= FACILITIES =================
                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  facilities.isEmpty
                      ? const Text('No facilities listed')
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: facilities.map((f) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              child: Text(
                                f,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 30),

                  // ================= ACTIONS =================
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
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
