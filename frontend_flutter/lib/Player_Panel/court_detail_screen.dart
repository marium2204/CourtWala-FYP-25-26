import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'booking_page.dart';
import 'player_home.dart';

class CourtDetailScreen extends StatelessWidget {
  final String courtName;
  final String location;
  final String sport;
  final String price;
  final String image;

  const CourtDetailScreen({
    super.key,
    required this.courtName,
    required this.location,
    required this.sport,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 80), // leave space for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image + back button
                Stack(
                  children: [
                    Image.asset(
                      image,
                      width: double.infinity,
                      height: 270,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 270,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Text(
                        courtName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 40,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _infoRow("📍 Location", location),
                          const SizedBox(height: 12),
                          _infoRow("🏅 Sport", sport),
                          const SizedBox(height: 12),
                          _infoRow("💸 Price", price, highlight: true),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // About + Facilities
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About This Court",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.headingBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "This court is well-maintained with high-quality flooring, professional lighting, and a clean environment. "
                            "Ideal for training, friendly matches, and weekend recreation.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Facilities",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.headingBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: const [
                              FacilityChip(
                                  icon: Icons.local_parking, label: "Parking"),
                              FacilityChip(
                                  icon: Icons.lightbulb_outline,
                                  label: "Indoor Lights"),
                              FacilityChip(icon: Icons.shower, label: "Shower"),
                              FacilityChip(
                                  icon: Icons.sports_tennis,
                                  label: "Equipment Rental"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Book Now button fixed at bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        courtName: courtName,
                        location: location,
                        sport: sport,
                        price: price,
                        image: image,
                        onBookingComplete: (index) {
                          Navigator.pop(context); // close CourtDetail
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PlayerHomeScreen()),
                          );
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 15, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Move this class **outside** CourtDetailScreen
class FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const FacilityChip({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundBeige.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.headingBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
