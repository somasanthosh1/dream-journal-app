import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../widgets/dream_card.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Dream> _allDreams = [];
  List<Dream> _results = [];
  String? _activeMood;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy',   'emoji': '✨'},
    {'label': 'Scary',   'emoji': '🌑'},
    {'label': 'Weird',   'emoji': '🌀'},
    {'label': 'Peaceful','emoji': '🌊'},
    {'label': 'Lucid',   'emoji': '💎'},
    {'label': 'Neutral', 'emoji': '🌫️'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _ctrl.addListener(_filter);
  }

  Future<void> _load() async {
    final dreams = await DreamStorage.getDreams();
    setState(() {
      _allDreams = dreams;
      _results = dreams;
    });
  }

  void _filter() {
    final q = _ctrl.text.toLowerCase();
    setState(() {
      _results = _allDreams.where((d) {
        final matchesQuery = q.isEmpty ||
            d.title.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.mood.toLowerCase().contains(q) ||
            d.tags.any((t) => t.toLowerCase().contains(q));
        final matchesMood = _activeMood == null || d.mood == _activeMood;
        return matchesQuery && matchesMood;
      }).toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: SafeArea(
        child: Column(
          children: [
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
                  const SizedBox(width: 14),
                  const Text(
                    'Search Dreams',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search title, mood, tags...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.auroraViolet, size: 20),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _ctrl.clear();
                            _filter();
                          },
                          child: const Icon(Icons.close,
                              color: AppTheme.textMuted, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.bg2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppTheme.auroraViolet, width: 1.5),
                  ),
                ),
              ),
            ),

            // Mood filter strip
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _MoodPill(
                    label: 'All',
                    emoji: '🌌',
                    color: AppTheme.textSecondary,
                    selected: _activeMood == null,
                    onTap: () {
                      setState(() => _activeMood = null);
                      _filter();
                    },
                  ),
                  ..._moods.map((m) => _MoodPill(
                        label: m['label'],
                        emoji: m['emoji'],
                        color: AppTheme.moodColor(m['label']),
                        selected: _activeMood == m['label'],
                        onTap: () {
                          setState(() => _activeMood =
                              _activeMood == m['label'] ? null : m['label']);
                          _filter();
                        },
                      )),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Row(
                children: [
                  Text(
                    '${_results.length} dream${_results.length != 1 ? 's' : ''} found',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.bg2,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(Icons.search_off_rounded,
                                size: 36, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),
                          const Text('No dreams found',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      itemBuilder: (context, i) => DreamCard(
                        dream: _results[i],
                        onDelete: () async {
                          await DreamStorage.deleteDream(_results[i].id);
                          _load();
                        },
                        onRefresh: _load,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MoodPill({
    required this.label,
    required this.emoji,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppTheme.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppTheme.textMuted,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
