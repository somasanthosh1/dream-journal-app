import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../screens/dream_detail_screen.dart';
import '../theme/app_theme.dart';

class DreamCard extends StatefulWidget {
  final Dream dream;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<DreamCard> createState() => _DreamCardState();
}

class _DreamCardState extends State<DreamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.dream.mood;
    final moodColor = AppTheme.moodColor(mood);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DreamDetailScreen(
              dream: widget.dream,
              onRefresh: widget.onRefresh,
            ),
            transitionsBuilder: (_, a, __, c) => FadeTransition(
              opacity: a,
              child: c,
            ),
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: moodColor.withOpacity(0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: moodColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle left accent bar
              Positioned(
                left: 0,
                top: 14,
                bottom: 14,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        moodColor,
                        moodColor.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Mood orb
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: moodColor.withOpacity(0.12),
                            border: Border.all(
                                color: moodColor.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              AppTheme.moodEmoji(mood),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.dream.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.dream.date),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (widget.dream.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.dream.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Mood pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mood,
                            style: TextStyle(
                              color: moodColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Tags
                        ...widget.dream.tags.take(2).map((t) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg3,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  '#$t',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.bg3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

