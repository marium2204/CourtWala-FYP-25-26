import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

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
              const SizedBox(height: 10),
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
                runSpacing: 8,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(c.address, style: AppTextStyles.subtitle),
                      const SizedBox(height: 6),
                      Text('PKR ${c.pricePerHour}/hour',
                          style: AppTextStyles.subtitle),

                      const SizedBox(height: 10),

                      Chip(
                        label: Text(c.status,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor:
                            _statusColor(c.status).withOpacity(0.15),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDetails(c),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Full Details'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // =======================
                      // STATUS ACTIONS (ADDED)
                      // =======================
                      if (_isPending(c.status)) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _updateCourtStatus(c, 'ACTIVE'),
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _updateCourtStatus(c, 'REJECTED'),
                                child: const Text('Reject',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (c.status == 'ACTIVE')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _updateCourtStatus(c, 'INACTIVE'),
                            child: const Text('Inactivate'),
                          ),
                        ),

                      if (c.status == 'INACTIVE' || c.status == 'REJECTED')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _updateCourtStatus(c, 'ACTIVE'),
                            child: const Text('Activate'),
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
