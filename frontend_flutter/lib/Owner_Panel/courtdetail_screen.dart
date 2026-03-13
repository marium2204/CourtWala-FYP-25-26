import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../Owner_Panel/edit_court_screen.dart';
import '../constants/api_constants.dart';

class CourtDetails extends StatefulWidget {
  final Map<String, dynamic> court;

  const CourtDetails({super.key, required this.court});

  @override
  State<CourtDetails> createState() => _CourtDetailsState();
}

class _CourtDetailsState extends State<CourtDetails> {
  int _currentImageIndex = 0;

  String get _imageBaseUrl => ApiConstants.baseUrl.replaceFirst('/api', '');

  List<String> get _images =>
      (widget.court['images'] as List?)?.cast<String>() ?? [];

  Widget _buildImageCarousel() {
    if (_images.isEmpty) {
      return _imagePlaceholder();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final raw = _images[index];
              final imageUrl =
                  raw.startsWith('http') ? raw : '$_imageBaseUrl$raw';

              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 10 : 6,
              height: _currentImageIndex == index ? 10 : 6,
              decoration: BoxDecoration(
                color: _currentImageIndex == index
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Opening location in Google Maps"),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final facilities =
        (widget.court['facilities'] as List?)?.cast<String>() ?? [];
    final mapUrl = widget.court['mapUrl'];
    final addressText = widget.court['location'];

    final List<Map<String, dynamic>> sports =
        (widget.court['sports'] as List?)?.cast<Map<String, dynamic>>() ?? [];

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
            const Text(
              'Court Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageCarousel(),
            ),
            const SizedBox(height: 24),
            _infoLine('Court Name', widget.court['name']),
            _infoLine('Description', widget.court['description']),
            _infoLine('Address', addressText),
            if (mapUrl != null && mapUrl.toString().isNotEmpty)
              TextButton.icon(
                onPressed: () => _openInMaps(context, mapUrl),
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps'),
              ),
            _infoLine('City', widget.court['city']),
            _infoLine(
              'Price / hour',
              '${widget.court['pricePerHour']} PKR',
            ),
            const SizedBox(height: 24),
            const Text(
              'Sports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: sports
                  .map(
                    (s) => Chip(
                      label: Text(s['name']),
                      backgroundColor: AppColors.primaryColor,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: facilities
                  .map(
                    (f) => Chip(
                      label: Text(f),
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    ),
                  )
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
                      builder: (_) => EditCourtScreen(court: widget.court),
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
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
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
