// lib/CourtOwner_Panel/owner_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import 'owner_profile_edit.dart';

class CourtOwnerProfileScreen extends StatelessWidget {
  const CourtOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ===== OWNER INFO =====
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.accentColor,
                child: const Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Court Owner Name",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingBlue)),
                  SizedBox(height: 2),
                  Text("Courts Managed: 3",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== STAT CARDS GRID =====
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _statCard("Total Courts", "3", AppColors.primaryColor,
                  width: 100),
              _statCard("Total Bookings", "20", Colors.orange, width: 100),
              _statCard("Pending Bookings", "5", Colors.redAccent, width: 100),
              _statCard("Approved Bookings", "15", Colors.green, width: 100),
              _statCard("Total Revenue", "\$12,500", AppColors.primaryColor,
                  width: 100),
              _statCard("Monthly Revenue", "\$2,300", Colors.orange,
                  width: 100),
            ],
          ),
          const SizedBox(height: 16),

          // ===== BAR CHART: Bookings Last 6 Months =====
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text("Bookings (Last 6 Months)",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingBlue)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  "May",
                                  "Jun",
                                  "Jul",
                                  "Aug",
                                  "Sep",
                                  "Oct"
                                ];
                                int index =
                                    value.toInt().clamp(0, months.length - 1);
                                return Text(months[index],
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(6, (index) {
                          final values = [3, 5, 4, 6, 7, 5];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                  toY: values[index].toDouble(),
                                  color: AppColors.primaryColor,
                                  width: 10)
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== PIE CHART: Booking Status =====
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Booking Status",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 5,
                              color: AppColors.primaryColor,
                              radius: 60,
                              title: "5",
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            PieChartSectionData(
                              value: 2,
                              color: Colors.orange,
                              radius: 60,
                              title: "2",
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            PieChartSectionData(
                              value: 1,
                              color: Colors.red,
                              radius: 60,
                              title: "1",
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 30,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegend(AppColors.primaryColor, "Confirmed"),
                      _buildLegend(Colors.orange, "Pending"),
                      _buildLegend(Colors.red, "Cancelled"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== PROFILE ACTIONS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OwnerEditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // ===== STAT CARD =====
  Widget _statCard(String title, String value, Color color,
      {double width = 100, double fontSize = 16}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: width,
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // ===== PIE CHART LEGEND =====
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
