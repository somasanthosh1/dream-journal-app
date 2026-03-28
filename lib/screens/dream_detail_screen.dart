import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import 'add_dream_screen.dart';

class DreamDetailScreen extends StatelessWidget {
  final Dream dream;
  final VoidCallback onRefresh;

  const DreamDetailScreen({
    super.key,
    required this.dream,
    required this.onRefresh,
  });

  Color _moodColor(String mood) {
    switch (mood) {
      case 'Happy': return const Color(0xFFFFD700);
      case 'Scary': return const Color(0xFFFF4444);
      case 'Weird': return const Color(0xFFFF8C00);
      case 'Peaceful': return const Color(0xFF4CAF50);
      default: return const Color(0xFF9E9E9E);
    }
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'Happy': return '😊';
      case 'Scary': return '😨';
      case 'Weird': return '🤔';
      case 'Peaceful': return '😌';
      default: return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF9B89FF)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddDreamScreen(dream: dream)),
              );
              onRefresh();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _moodColor(dream.mood).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _moodColor(dream.mood)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_moodEmoji(dream.mood), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        dream.mood,
                        style: TextStyle(
                          color: _moodColor(dream.mood),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${dream.date.day}/${dream.date.month}/${dream.date.year}',
                  style: const TextStyle(color: Color(0xFF9B89FF), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              dream.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF3A3A5C)),
            const SizedBox(height: 16),
            // Description
            if (dream.description.isNotEmpty) ...[
              const Text(
                'Dream Description',
                style: TextStyle(color: Color(0xFF9B89FF), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                dream.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.7,
                ),
              ),
            ] else
              const Text(
                'No description added.',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            const SizedBox(height: 40),
            // Delete button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFFF4444)),
                label: const Text('Delete Dream',
                    style: TextStyle(color: Color(0xFFFF4444), fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('Delete Dream',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                          'Are you sure you want to delete this dream?',
                          style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel',
                              style: TextStyle(color: Color(0xFF9B89FF))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Color(0xFFFF4444))),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DreamStorage.deleteDream(dream.id);
                    onRefresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
