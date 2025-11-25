import 'package:flutter/material.dart';
import '../theme/colors.dart';

// =====================
// Announcement Model
// =====================
class Announcement {
  String title;
  String message;
  List<String> targetAudience;
  DateTime? scheduledAt;
  bool isActive;
  DateTime createdAt;

  Announcement({
    required this.title,
    required this.message,
    required this.targetAudience,
    this.scheduledAt,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// =====================
// Announcements Page
// =====================
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> announcements = [
    Announcement(
      title: "Court Maintenance",
      message: "Courts will be closed on Sunday.",
      targetAudience: ["PLAYER", "COURT_OWNER"],
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
    ),
    Announcement(
      title: "New Booking Feature",
      message: "Players can now book courts online.",
      targetAudience: ["PLAYER"],
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _message = "";
  List<String> _targetAudience = [];
  DateTime? _scheduledAt;
  bool _isActive = true;

  int? _editingIndex;

  // =====================
  // Show Form Dialog
  // =====================
  void _showFormDialog({Announcement? ann, int? index}) {
    if (ann != null) {
      _title = ann.title;
      _message = ann.message;
      _targetAudience = List.from(ann.targetAudience);
      _scheduledAt = ann.scheduledAt;
      _isActive = ann.isActive;
      _editingIndex = index;
    } else {
      _title = "";
      _message = "";
      _targetAudience = [];
      _scheduledAt = null;
      _isActive = true;
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundBeige,
        title: Text(ann != null ? "Edit Announcement" : "New Announcement",
            style: const TextStyle(color: AppColors.headingBlue)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _title = val!,
                ),
                const SizedBox(height: 10),

                // Message
                TextFormField(
                  initialValue: _message,
                  decoration: const InputDecoration(labelText: "Message"),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _message = val!,
                ),
                const SizedBox(height: 10),

                // Target Audience
                Wrap(
                  spacing: 10,
                  children: ["PLAYER", "COURT_OWNER"].map((aud) {
                    return FilterChip(
                      label: Text(aud),
                      selected: _targetAudience.contains(aud),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _targetAudience.add(aud);
                          } else {
                            _targetAudience.remove(aud);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Scheduled At
                Row(
                  children: [
                    Text(
                      _scheduledAt != null
                          ? "Scheduled: ${_scheduledAt!.toLocal()}"
                          : "No Schedule",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduledAt ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          TimeOfDay? time = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            setState(() {
                              _scheduledAt = DateTime(picked.year, picked.month,
                                  picked.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                      child: const Text("Pick Date/Time"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Active toggle
                Row(
                  children: [
                    const Text("Active"),
                    Switch(
                      value: _isActive,
                      onChanged: (val) {
                        setState(() {
                          _isActive = val;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _targetAudience.isNotEmpty) {
                  _formKey.currentState!.save();
                  setState(() {
                    final newAnn = Announcement(
                        title: _title,
                        message: _message,
                        targetAudience: _targetAudience,
                        scheduledAt: _scheduledAt,
                        isActive: _isActive);
                    if (_editingIndex != null) {
                      announcements[_editingIndex!] = newAnn;
                    } else {
                      announcements.add(newAnn);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  // =====================
  // Delete Announcement
  // =====================
  void _deleteAnnouncement(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Announcement"),
        content:
            const Text("Are you sure you want to delete this announcement?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                setState(() {
                  announcements.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }

  // =====================
  // Build Table/List
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Announcements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFormDialog(),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (_, index) {
          final ann = announcements[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(ann.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingBlue)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ann.message),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: ann.targetAudience
                        .map((e) => Chip(
                              label: Text(e,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                              backgroundColor:
                                  AppColors.primaryColor.withOpacity(0.8),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Scheduled: ${ann.scheduledAt != null ? ann.scheduledAt!.toLocal() : 'N/A'}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text("Active: ${ann.isActive ? 'Yes' : 'No'}",
                      style: const TextStyle(fontSize: 12)),
                  Text(
                      "Created: ${ann.createdAt.toLocal().toString().split('.')[0]}",
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon:
                          const Icon(Icons.edit, color: AppColors.primaryColor),
                      onPressed: () => _showFormDialog(ann: ann, index: index)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteAnnouncement(index)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
