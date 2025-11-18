// lib/Player_Panel/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<Map<String, String>> recentMatches = [
    {
      "opponent": "Alice",
      "sport": "Badminton",
      "result": "Win",
      "score": "21-15, 21-18",
      "date": "Oct 5"
    },
    {
      "opponent": "Bob",
      "sport": "Tennis",
      "result": "Loss",
      "score": "4-6, 6-7",
      "date": "Oct 3"
    },
    {
      "opponent": "Charlie",
      "sport": "Football",
      "result": "Win",
      "score": "3-1",
      "date": "Sep 28"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ===== USER INFO =====
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
                  Text("John Doe",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingBlue)),
                  SizedBox(height: 2),
                  Text("Sport: Badminton",
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
              _statCard("Matches", "24", AppColors.primaryColor,
                  width: 80, fontSize: 16),
              _statCard("Wins", "12", Colors.orange, width: 80, fontSize: 16),
              _statCardWithArrow("Streak", "3", Colors.green,
                  width: 80, fontSize: 16),
              _statCard("Win %", "50%", AppColors.accentColor,
                  width: 80, fontSize: 16),
            ],
          ),
          const SizedBox(height: 16),

          // ===== PIE CHART: Win/Loss =====
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Win/Loss Ratio",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingBlue)),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 12,
                              color: AppColors.primaryColor,
                              radius: 60,
                              title: "12",
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            PieChartSectionData(
                              value: 12,
                              color: Colors.orange,
                              radius: 60,
                              title: "12",
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
                      _buildLegend(AppColors.primaryColor, "Wins"),
                      _buildLegend(Colors.orange, "Losses"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== BAR CHART =====
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text("Matches Played (Last 6 Months)",
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
                          final values = [4, 6, 7, 5, 8, 6];
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

          // ===== RECENT MATCHES =====
          const Text("Recent Matches",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingBlue)),
          const SizedBox(height: 8),
          Column(
            children: recentMatches.map((match) {
              final bool isWin = match["result"] == "Win";
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
                        isWin ? AppColors.primaryColor : Colors.orange,
                    child: Text(match["opponent"]![0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(match["opponent"]!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.headingBlue)),
                  subtitle: Text("${match["sport"]} • ${match["score"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Text(match["result"]!,
                      style: TextStyle(
                          color: isWin ? AppColors.primaryColor : Colors.orange,
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
                        builder: (_) => const EditProfileScreen()),
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
