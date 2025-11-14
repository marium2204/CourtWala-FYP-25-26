// lib/CourtOwner_Panel/owner_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import 'owner_profile_edit.dart';

class CourtOwnerProfileScreen extends StatelessWidget {
  const CourtOwnerProfileScreen({super.key});

  static const List<Map<String, String>> recentBookings = [
    {
      "player": "Ali Ahmed",
      "court": "Elite Badminton Arena",
      "status": "Confirmed",
      "date": "Nov 12"
    },
    {
      "player": "Saad Khan",
      "court": "Champions Cricket Ground",
      "status": "Pending",
      "date": "Nov 14"
    },
    {
      "player": "Hassan Tariq",
      "court": "Padel Court Central",
      "status": "Completed",
      "date": "Nov 16"
    },
  ];

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

          // ===== STAT CARDS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard("Total Courts", "3", AppColors.primaryColor,
                  width: 80, fontSize: 16),
              _statCard("Active Bookings", "5", Colors.orange,
                  width: 80, fontSize: 16),
              _statCardWithArrow("Completed", "12", Colors.green,
                  width: 80, fontSize: 16),
              _statCard("Cancelled %", "10%", AppColors.accentColor,
                  width: 80, fontSize: 16),
            ],
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
                  // ===== LEGEND =====
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

          // ===== RECENT BOOKINGS =====
          const Text("Recent Bookings",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingBlue)),
          const SizedBox(height: 8),
          Column(
            children: recentBookings.map((booking) {
              final bool isConfirmed = booking["status"] == "Confirmed";
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  leading: CircleAvatar(
                    backgroundColor:
                        isConfirmed ? AppColors.primaryColor : Colors.orange,
                    child: Text(booking["player"]![0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(booking["player"]!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.headingBlue)),
                  subtitle: Text("${booking["court"]} • ${booking["date"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Text(booking["status"]!,
                      style: TextStyle(
                          color: isConfirmed
                              ? AppColors.primaryColor
                              : Colors.orange,
                          fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ===== BUTTONS =====
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
      {double width = 80, double fontSize = 16}) {
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

  // ===== STAT CARD WITH ARROW =====
  Widget _statCardWithArrow(String title, String value, Color color,
      {double width = 80, double fontSize = 16}) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
              ],
            ),
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
