import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Map<String, String>> allChallenges = const [
    {
      "title": "Weekend Tournament",
      "subtitle": "Join and win prizes",
      "sport": "Badminton",
      "level": "Intermediate"
    },
    {
      "title": "5-a-side Football Challenge",
      "subtitle": "Register teams",
      "sport": "Football",
      "level": "Advanced"
    },
    {
      "title": "Padel Doubles Match",
      "subtitle": "Sign up with a partner",
      "sport": "Padel",
      "level": "Beginner"
    },
    {
      "title": "Cricket Fun League",
      "subtitle": "Participate in mini matches",
      "sport": "Cricket",
      "level": "Intermediate"
    },
  ];

  List<Map<String, String>> filteredChallenges = [];

  String? selectedSport;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    filteredChallenges = List.from(allChallenges);
  }

  void _applyFilters() {
    setState(() {
      filteredChallenges = allChallenges.where((challenge) {
        final matchesSport =
            selectedSport == null || challenge['sport'] == selectedSport;
        final matchesLevel =
            selectedLevel == null || challenge['level'] == selectedLevel;
        return matchesSport && matchesLevel;
      }).toList();
    });
    Navigator.pop(context);
  }

  void _removeFilters() {
    setState(() {
      selectedSport = null;
      selectedLevel = null;
      filteredChallenges = List.from(allChallenges);
    });
    Navigator.pop(context);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sport Dropdown
              DropdownButtonFormField<String>(
                value: selectedSport,
                decoration: InputDecoration(
                  labelText: "Sport",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ["Badminton", "Football", "Padel", "Cricket"]
                    .map((sport) => DropdownMenuItem(
                          value: sport,
                          child: Text(sport),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedSport = value),
              ),
              const SizedBox(height: 12),

              // Level Dropdown
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: InputDecoration(
                  labelText: "Level",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ["Beginner", "Intermediate", "Advanced"]
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLevel = value),
              ),
              const SizedBox(height: 20),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _removeFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Remove Filters",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openFilterSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    label: const Text(
                      "Filters",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Challenges List
            Expanded(
              child: ListView.builder(
                itemCount: filteredChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = filteredChallenges[index];
                  return _challengeCard(challenge);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard(Map<String, String> challenge) {
    return GestureDetector(
      onTap: () {
        // Optional: Open challenge details
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challenge['subtitle']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _levelColor(challenge['level']!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            challenge['level']!,
                            style: TextStyle(
                                color: _levelColor(challenge['level']!),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sport badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            challenge['sport']!,
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Join button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  "Join",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
