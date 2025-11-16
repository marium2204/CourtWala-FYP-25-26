// lib/Admin_Panel/announcements_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, String>> announcements = [
    {
      'title': 'New Court Opening',
      'description': 'Elite Badminton Arena will open a new court on Nov 20.',
      'date': '2025-11-15',
    },
    {
      'title': 'Maintenance Notice',
      'description': 'Court 3 will be closed for maintenance on Nov 18.',
      'date': '2025-11-14',
    },
  ];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _addAnnouncement() {
    _titleController.clear();
    _descriptionController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {
                  setState(() {
                    announcements.add({
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'date': DateTime.now().toIso8601String().split('T')[0],
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _editAnnouncement(int index) {
    _titleController.text = announcements[index]['title']!;
    _descriptionController.text = announcements[index]['description']!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  announcements[index]['title'] = _titleController.text;
                  announcements[index]['description'] =
                      _descriptionController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _deleteAnnouncement(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  announcements.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _addAnnouncement, icon: const Icon(Icons.add))
        ],
      ),
      body: announcements.isEmpty
          ? const Center(child: Text('No announcements available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = announcements[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    title: Text(item['title']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingBlue)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description']!),
                        const SizedBox(height: 4),
                        Text(item['date']!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editAnnouncement(index)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
