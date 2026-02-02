import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../Owner_Panel/edit_court_screen.dart';
import '../constants/api_constants.dart';

class CourtDetails extends StatelessWidget {
  final Map<String, dynamic> court;

  const CourtDetails({super.key, required this.court});

  String get _imageBaseUrl => ApiConstants.baseUrl.replaceFirst('/api', '');

  Widget _buildImage() {
    final images = (court['images'] as List?)?.cast<String>() ?? [];

    if (images.isEmpty) {
      return _imagePlaceholder();
    }

    final raw = images.first;
    final imageUrl = raw.startsWith('http') ? raw : '$_imageBaseUrl$raw';

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
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

    final List<Map<String, dynamic>> sports =
        (court['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Court Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Court Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),
            const SizedBox(height: 24),
            _infoLine('Court Name', court['name']),
            _infoLine('Description', court['description']),
            _infoLine('Address', addressText),
            if (mapUrl != null && mapUrl.toString().isNotEmpty)
              TextButton.icon(
                onPressed: () => _openInMaps(context, mapUrl),
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps'),
              ),
            _infoLine('City', court['city']),
            _infoLine('Price / hour', '${court['pricePerHour']} PKR'),
            const SizedBox(height: 24),
            const Text('Sports',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: sports
                  .map((s) => Chip(
                        label: Text(s['name']),
                        backgroundColor: AppColors.primaryColor,
                        labelStyle: const TextStyle(color: Colors.white),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('Facilities',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: facilities
                  .map((f) => Chip(
                        label: Text(f),
                        backgroundColor:
                            AppColors.primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 36),
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
                label: const Text('Edit Court',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value?.toString() ?? 'N/A',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
