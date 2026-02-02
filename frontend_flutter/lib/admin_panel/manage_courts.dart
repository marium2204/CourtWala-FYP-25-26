import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

/// =======================
/// COURT MODEL
/// =======================
class Court {
  final String id;
  final String name;
  final List<String> sports;
  final String address;
  final String mapUrl;
  final double pricePerHour;
  final String status;
  final List<String> amenities;
  final List<String> images;

  Court({
    required this.id,
    required this.name,
    required this.sports,
    required this.address,
    required this.mapUrl,
    required this.pricePerHour,
    required this.status,
    required this.amenities,
    required this.images,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Court',
      sports: (json['sports'] as List? ?? [])
          .map((s) => s['name'].toString())
          .toList(),
      address: [
        json['address'],
        json['city'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
      mapUrl: json['mapUrl'] ?? '',
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'PENDING_APPROVAL',
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

/// =======================
/// SCREEN
/// =======================
class ManageCourtsScreen extends StatefulWidget {
  final String adminToken;

  const ManageCourtsScreen({super.key, required this.adminToken});

  @override
  State<ManageCourtsScreen> createState() => _ManageCourtsScreenState();
}

class _ManageCourtsScreenState extends State<ManageCourtsScreen> {
  List<Court> courts = [];
  bool isLoading = true;

  String get _imageBaseUrl => ApiConstants.baseUrl.replaceFirst('/api', '');

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    final res = await ApiService.get('/admin/courts', widget.adminToken);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['data']['courts'] ?? [];
      setState(() {
        courts = list.map((e) => Court.fromJson(e)).toList();
        isLoading = false;
      });
    }
  }

  Future<void> _updateCourtStatus(Court c, String status) async {
    await ApiService.put(
      '/admin/courts/${c.id}/status',
      widget.adminToken,
      {'status': status},
    );
    _fetchCourts();
  }

  Widget _statusActions(Court c) {
    switch (c.status) {
      case 'PENDING_APPROVAL':
        return Row(
          children: [
            OutlinedButton(
              onPressed: () => _updateCourtStatus(c, 'ACTIVE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
              child: const Text('Approve'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => _updateCourtStatus(c, 'REJECTED'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );

      case 'ACTIVE':
        return OutlinedButton(
          onPressed: () => _updateCourtStatus(c, 'INACTIVE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
          ),
          child: const Text('Suspend'),
        );

      case 'INACTIVE':
        return OutlinedButton(
          onPressed: () => _updateCourtStatus(c, 'ACTIVE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
          ),
          child: const Text('Activate'),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  bool _isPending(String status) => status == 'PENDING_APPROVAL';

  /// =======================
  /// IMAGE HELPERS
  /// =======================
  String _resolveImage(String raw) {
    if (raw.startsWith('http')) return raw;
    return '$_imageBaseUrl$raw';
  }

  Widget _courtThumbnail(Court c) {
    if (c.images.isEmpty) {
      return _imagePlaceholder(80);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _resolveImage(c.images.first),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(80),
      ),
    );
  }

  Widget _imagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported),
    );
  }

  /// =======================
  /// OPEN GOOGLE MAPS
  /// =======================
  Future<void> _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// =======================
  /// VIEW FULL DETAILS
  /// =======================
  Future<void> _showDetails(Court c) async {
    final res =
        await ApiService.get('/admin/courts/${c.id}', widget.adminToken);
    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body)['data'];
    final List slots = data['slots'] ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name, style: AppTextStyles.title),
              const SizedBox(height: 12),

              // ================= IMAGES =================
              if (c.images.isNotEmpty) ...[
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: c.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _resolveImage(c.images[i]),
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (c.mapUrl.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _openMap(c.mapUrl),
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text('Open Google Maps',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),

              _section('Sports'),
              Wrap(
                spacing: 8,
                children: c.sports.map((s) => Chip(label: Text(s))).toList(),
              ),

              _section('Amenities'),
              Wrap(
                spacing: 8,
                children: c.amenities.map((a) => Chip(label: Text(a))).toList(),
              ),

              _section('Slots'),
              slots.isEmpty
                  ? const Text('No slots')
                  : Column(
                      children: slots.map((s) {
                        return ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text('${s['startTime']} - ${s['endTime']}'),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title:
            const Text('Manage Courts', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courts.length,
              itemBuilder: (_, i) {
                final c = courts[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _courtThumbnail(c),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: AppTextStyles.title),
                            Text(c.address, style: AppTextStyles.subtitle),
                            Text('PKR ${c.pricePerHour}/hour',
                                style: AppTextStyles.subtitle),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(c.status,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              backgroundColor:
                                  _statusColor(c.status).withOpacity(0.15),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _showDetails(c),
                              icon: const Icon(Icons.visibility),
                              label: const Text('View Full Details'),
                            ),
                            _statusActions(c),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
