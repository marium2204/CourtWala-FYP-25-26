// lib/CourtOwner_Panel/owner_bookings_screen.dart
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

  String selectedStatusFilter = 'All';
  DateTime? selectedDateFilter;

  // ---------------- SAMPLE BOOKING DATA ----------------
  List<Map<String, dynamic>> bookings = [
    {
      'id': 'BKG001',
      'player': 'Ali Ahmed',
      'court': 'Elite Badminton Arena',
      'date': DateTime(2025, 11, 12),
      'startTime': '7:00 PM',
      'endTime': '8:00 PM',
      'status': 'Pending',
      'needsOpponent': 'Yes',
      'totalPrice': 100
    },
    {
      'id': 'BKG002',
      'player': 'Saad Khan',
      'court': 'Champions Cricket Ground',
      'date': DateTime(2025, 11, 14),
      'startTime': '5:00 PM',
      'endTime': '7:00 PM',
      'status': 'Confirmed',
      'needsOpponent': 'No',
      'totalPrice': 250
    },
    {
      'id': 'BKG003',
      'player': 'Hassan Tariq',
      'court': 'Padel Court Central',
      'date': DateTime(2025, 11, 16),
      'startTime': '4:00 PM',
      'endTime': '5:00 PM',
      'status': 'Completed',
      'needsOpponent': 'No',
      'totalPrice': 150
    },
    {
      'id': 'BKG004',
      'player': 'Bilal Ahmed',
      'court': 'Elite Badminton Arena',
      'date': DateTime(2025, 11, 10),
      'startTime': '6:00 PM',
      'endTime': '7:00 PM',
      'status': 'Cancelled',
      'needsOpponent': 'Yes',
      'totalPrice': 80
    },
  ];

  // ---------------- FILTER BOOKING LIST ----------------
  List<Map<String, dynamic>> filterBookings(String status) {
    return bookings.where((b) {
      bool matchesStatus =
          status == 'All' ? true : b['status'].toString() == status;
      bool matchesDate =
          selectedDateFilter == null ? true : b['date'] == selectedDateFilter;
      return matchesStatus && matchesDate;
    }).toList();
  }

  void updateStatus(Map<String, dynamic> booking, String newStatus) {
    setState(() {
      booking['status'] = newStatus;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: Column(
        children: [
          // ---------------- FILTERS ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Status Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatusFilter,
                    items: [
                      'All',
                      'Pending',
                      'Confirmed',
                      'Completed',
                      'Cancelled',
                      'Rejected'
                    ]
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedStatusFilter = val!;
                      });
                    },
                    decoration: const InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                // Date Picker
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDateFilter = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(selectedDateFilter == null
                          ? "Filter by Date"
                          : "${selectedDateFilter!.day}-${selectedDateFilter!.month}-${selectedDateFilter!.year}"),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDateFilter = null;
                      selectedStatusFilter = 'All';
                    });
                  },
                  icon: const Icon(Icons.clear, color: Colors.red),
                ),
              ],
            ),
          ),

          // ---------------- TAB BAR ----------------
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Confirmed"),
                Tab(text: "Completed"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),

          // ---------------- TAB CONTENT ----------------
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList('All'),
                _buildBookingList('Pending'),
                _buildBookingList('Confirmed'),
                _buildBookingList('Completed'),
                _buildBookingList('Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(String status) {
    final list = filterBookings(status);

    if (list.isEmpty) {
      return const Center(
        child: Text("No bookings available",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];

        // Status text color
        Color statusColor = b['status'] == 'Pending'
            ? Colors.orange
            : b['status'] == 'Confirmed'
                ? Colors.green
                : b['status'] == 'Completed'
                    ? Colors.blue
                    : b['status'] == 'Cancelled'
                        ? Colors.red
                        : Colors.grey;

        // Status text with description
        String statusText = b['status'] == 'Pending'
            ? 'Needs Approval'
            : b['status'] == 'Confirmed'
                ? 'Confirmed'
                : b['status'] == 'Completed'
                    ? 'Completed'
                    : b['status'] == 'Cancelled'
                        ? 'Cancelled'
                        : 'Rejected';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge with icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      b['status'] == 'Pending'
                          ? Icons.hourglass_top
                          : b['status'] == 'Confirmed'
                              ? Icons.check_circle
                              : b['status'] == 'Completed'
                                  ? Icons.done_all
                                  : b['status'] == 'Cancelled'
                                      ? Icons.cancel
                                      : Icons.block,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text("Booking ID: ${b['id']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingBlue)),
                const SizedBox(height: 4),
                Text("Player: ${b['player']}"),
                Text("Court: ${b['court']}"),
                Text(
                    "Date: ${b['date'].day}-${b['date'].month}-${b['date'].year}"),
                Text("Time: ${b['startTime']} - ${b['endTime']}"),
                Text("Needs Opponent: ${b['needsOpponent']}"),
                Text("Total Price: \$${b['totalPrice']}"),
                const SizedBox(height: 8),

                // Action buttons
                if (b['status'] == 'Pending') _pendingButtons(b),
                if (b['status'] == 'Confirmed') _cancelButton(b),
                if (['Completed', 'Cancelled', 'Rejected']
                    .contains(b['status']))
                  const Text("No actions available",
                      style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- BUTTONS ----------------
  Widget _pendingButtons(Map<String, dynamic> booking) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => updateStatus(booking, "Confirmed"),
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
            onPressed: () => updateStatus(booking, "Cancelled"),
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

  Widget _cancelButton(Map<String, dynamic> booking) {
    return ElevatedButton(
      onPressed: () => updateStatus(booking, "Cancelled"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
    );
  }
}
