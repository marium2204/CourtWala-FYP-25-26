import 'package:courtwala/Owner_Panel/edit_court_screen.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
//import '../Owner_Panel/courtdetail_screen.dart';

class CourtDetails extends StatelessWidget {
  final String courtName;
  final String location;
  final String sport;
  final String price;
  final String image;
  final List<String> facilities;
  final double rating;
  final int bookings;

  const CourtDetails({
    super.key,
    required this.courtName,
    required this.location,
    required this.sport,
    required this.price,
    required this.image,
    this.facilities = const [
      'Parking',
      'Indoor Lights',
      'Shower',
      'Equipment Rental'
    ],
    this.rating = 0.0,
    this.bookings = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(courtName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Court Image with Overlay
            Stack(
              children: [
                Hero(
                  tag: courtName,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Court Name & Sport
                  Text(
                    courtName,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.sports_tennis,
                          size: 20, color: AppColors.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        sport,
                        style: const TextStyle(
                            fontSize: 16, color: AppColors.accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location & Price Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(location,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            Text(price,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 20),
                            const Icon(Icons.calendar_today,
                                color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            Text("$bookings bookings",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Facilities Section
                  const Text("Facilities",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: facilities
                        .map((facility) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.primaryColor, width: 1),
                              ),
                              child: Text(
                                facility,
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final courtData = {
                              'name': courtName,
                              'location': location,
                              'sport': sport,
                              'price': price,
                              'image': image,
                              'facilities': facilities,
                              'rating': rating,
                              'bookings': bookings,
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditCourtScreen(court: courtData),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Edit Court",
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
                      const SizedBox(width: 16),
                    ],
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
}
