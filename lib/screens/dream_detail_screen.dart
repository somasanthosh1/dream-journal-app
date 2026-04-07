import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../theme/app_theme.dart';
import 'add_dream_screen.dart';

class DreamDetailScreen extends StatelessWidget {
  final Dream dream;
  final VoidCallback onRefresh;

  const DreamDetailScreen({
    super.key,
    required this.dream,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = AppTheme.moodColor(dream.mood);
    final moodEmoji = AppTheme.moodEmoji(dream.mood);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Stack(
        children: [
          // Mood-colored aurora glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    moodColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.bg2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.textSecondary, size: 18),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddDreamScreen(dream: dream)),
                          );
                          onRefresh();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.auroraViolet.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.auroraViolet.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: AppTheme.auroraViolet, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood hero
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: moodColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: moodColor.withOpacity(0.15),
                                  border: Border.all(
                                      color: moodColor.withOpacity(0.4),
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moodColor.withOpacity(0.25),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(moodEmoji,
                                      style: const TextStyle(fontSize: 26)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dream.mood,
                                    style: TextStyle(
                                      color: moodColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _fullDate(dream.date),
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          dream.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),

                        if (dream.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            children: dream.tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bg2,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.border),
                                      ),
                                      child: Text(
                                        '#$t',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],

                        const SizedBox(height: 24),
                        Container(height: 1, color: AppTheme.border),
                        const SizedBox(height: 20),

                        // Description
                        const Text(
                          'DREAM LOG',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        dream.description.isNotEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg2,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  dream.description,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 15,
                                    height: 1.8,
                                  ),
                                ),
                              )
                            : const Text(
                                'No description recorded.',
                                style: TextStyle(
                                    color: AppTheme.textMuted, fontSize: 15),
                              ),

                        const SizedBox(height: 40),

                        // Delete button
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.bg2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Dream',
                                    style: TextStyle(
                                        color: AppTheme.textPrimary)),
                                content: const Text(
                                    'This dream will be lost forever.',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Color(0xFFEF4444))),
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
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFEF4444).withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Dream',
                                  style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fullDate(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
