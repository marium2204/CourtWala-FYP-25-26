import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CourtOwnerBookingsScreen extends StatefulWidget {
  const CourtOwnerBookingsScreen({super.key});

  @override
  State<CourtOwnerBookingsScreen> createState() =>
      _CourtOwnerBookingsScreenState();
}

class _CourtOwnerBookingsScreenState extends State<CourtOwnerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ---------------- SAMPLE BOOKING DATA ----------------
  List<Map<String, dynamic>> bookings = [
    {
      'player': 'Ali Ahmed',
      'court': 'Elite Badminton Arena',
      'date': '12 Nov 2025',
      'time': '7:00 PM - 8:00 PM',
      'status': 'Pending'
    },
    {
      'player': 'Saad Khan',
      'court': 'Champions Cricket Ground',
      'date': '14 Nov 2025',
      'time': '5:00 PM - 7:00 PM',
      'status': 'Confirmed'
    },
    {
      'player': 'Hassan Tariq',
      'court': 'Padel Court Central',
      'date': '16 Nov 2025',
      'time': '4:00 PM - 5:00 PM',
      'status': 'Completed'
    },
    {
      'player': 'Bilal Ahmed',
      'court': 'Elite Badminton Arena',
      'date': '10 Nov 2025',
      'time': '6:00 PM - 7:00 PM',
      'status': 'Cancelled'
    }
  ];

  // Filter list by status
  List<Map<String, dynamic>> filterBookings(String status) {
    return bookings.where((b) => b['status'] == status).toList();
  }

  // Update status in main list
  void updateStatus(int index, String oldStatus, String newStatus) {
    // Find actual booking index in full list
    final booking = filterBookings(oldStatus)[index];
    final realIndex = bookings.indexOf(booking);

    setState(() {
      bookings[realIndex]['status'] = newStatus;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------- TAB BAR ----------------
        Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,

              // 🔥 Add padding so the last tab is fully accessible
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),

              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Confirmed"),
                Tab(text: "Completed"),
                Tab(text: "Cancelled"),
              ],
            )),

        // ---------------- TAB CONTENT ----------------
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList("Pending"),
              _buildBookingList("Confirmed"),
              _buildBookingList("Completed"),
              _buildBookingList("Cancelled"),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- BOOKING LIST UI ----------------
  Widget _buildBookingList(String status) {
    final list = filterBookings(status);

    if (list.isEmpty) {
      return const Center(
        child: Text("No bookings available",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b['player'],
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingBlue)),
              const SizedBox(height: 4),
              Text("🏟️ ${b['court']}",
                  style: const TextStyle(color: Colors.grey)),
              Text("📅 ${b['date']}"),
              Text("⏰ ${b['time']}"),

              const SizedBox(height: 12),

              // ---------------- ACTION BUTTONS ----------------
              if (status == "Pending") _pendingButtons(index),
              if (status == "Confirmed") _cancelButton(index),
              if (status == "Completed" || status == "Cancelled")
                const Text("No actions available",
                    style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  // ---------------- BUTTON: APPROVE / REJECT ----------------
  Widget _pendingButtons(int index) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => updateStatus(index, "Pending", "Confirmed"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => updateStatus(index, "Pending", "Cancelled"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ---------------- BUTTON: CANCEL BOOKING ----------------
  Widget _cancelButton(int index) {
    return ElevatedButton(
      onPressed: () => updateStatus(index, "Confirmed", "Cancelled"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
    );
  }
}
