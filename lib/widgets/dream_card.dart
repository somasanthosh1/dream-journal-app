import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../screens/dream_detail_screen.dart';

class DreamCard extends StatelessWidget {
  final Dream dream;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onDelete,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DreamDetailScreen(
              dream: dream,
              onRefresh: onRefresh,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _moodColor(dream.mood).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _moodColor(dream.mood).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_moodEmoji(dream.mood),
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dream.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${dream.date.day}/${dream.date.month}/${dream.date.year}',
                    style: const TextStyle(
                        color: Color(0xFF9B89FF), fontSize: 12),
                  ),
                ],
              ),
              if (dream.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  dream.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _moodColor(dream.mood).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dream.mood,
                      style: TextStyle(
                        color: _moodColor(dream.mood),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline,
                        color: Color(0xFF555580), size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
