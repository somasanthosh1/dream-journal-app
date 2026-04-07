import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../widgets/dream_card.dart';
import '../theme/app_theme.dart';
import 'add_dream_screen.dart';
import 'search_screen.dart';

enum SortMode { newest, oldest, mood }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Dream> _dreams = [];
  bool _loading = true;
  SortMode _sortMode = SortMode.newest;
  String? _filterMood;
  DateTimeRange? _filterRange;
  late AnimationController _fabAnim;

  final List<String> _moods = ['Happy', 'Scary', 'Weird', 'Peaceful', 'Lucid', 'Neutral'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _loadDreams();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  Future<void> _loadDreams() async {
    setState(() => _loading = true);
    final dreams = await DreamStorage.getDreams();
    setState(() {
      _dreams = dreams;
      _loading = false;
    });
  }

  List<Dream> get _filteredDreams {
    var list = List<Dream>.from(_dreams);
    if (_filterMood != null) {
      list = list.where((d) => d.mood == _filterMood).toList();
    }
    if (_filterRange != null) {
      list = list.where((d) {
        final day = DateTime(d.date.year, d.date.month, d.date.day);
        return !day.isBefore(_filterRange!.start) &&
            !day.isAfter(_filterRange!.end);
      }).toList();
    }
    switch (_sortMode) {
      case SortMode.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortMode.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortMode.mood:
        list.sort((a, b) => a.mood.compareTo(b.mood));
        break;
    }
    return list;
  }

  Map<String, List<Dream>> _groupByDate(List<Dream> list) {
    final map = <String, List<Dream>>{};
    for (final d in list) {
      final key = _dateLabel(d.date);
      map.putIfAbsent(key, () => []).add(d);
    }
    return map;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _filterRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.auroraViolet,
            surface: AppTheme.bg2,
            onSurface: AppTheme.textPrimary,
          ),
          dialogBackgroundColor: AppTheme.bg1,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _filterRange = picked);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        currentMood: _filterMood,
        currentSort: _sortMode,
        currentRange: _filterRange,
        moods: _moods,
        onApply: (mood, sort, range) {
          setState(() {
            _filterMood = mood;
            _sortMode = sort;
            _filterRange = range;
          });
          Navigator.pop(context);
        },
        onPickDate: _pickDateRange,
      ),
    );
  }

  bool get _hasFilters => _filterMood != null || _filterRange != null || _sortMode != SortMode.newest;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDreams;
    final grouped = _groupByDate(filtered);
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Stack(
        children: [
          // Aurora top glow
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.auroraViolet.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildStatsBar(),
                if (_hasFilters) _buildActiveFilters(),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.auroraViolet,
                            strokeWidth: 2,
                          ),
                        )
                      : filtered.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: groupKeys.length,
                              itemBuilder: (context, i) {
                                final key = groupKeys[i];
                                final items = grouped[key]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _DateHeader(label: key),
                                    ...items.map((d) => DreamCard(
                                          dream: d,
                                          onDelete: () async {
                                            await DreamStorage.deleteDream(d.id);
                                            _loadDreams();
                                          },
                                          onRefresh: _loadDreams,
                                        )),
                                  ],
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: _GlowFAB(
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AddDreamScreen(),
                transitionsBuilder: (_, a, __, c) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                  child: c,
                ),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
            _loadDreams();
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.nightlight_round,
                      color: AppTheme.auroraViolet, size: 20),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppTheme.textPrimary, AppTheme.textSecondary],
                    ).createShader(b),
                    child: const Text(
                      'Dream Journal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _greetingText(),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.search_rounded,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              _loadDreams();
            },
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.tune_rounded,
            badge: _hasFilters,
            onTap: _showFilterSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final moodCounts = <String, int>{};
    for (final d in _dreams) {
      moodCounts[d.mood] = (moodCounts[d.mood] ?? 0) + 1;
    }
    final topMood = moodCounts.isEmpty
        ? null
        : moodCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          _StatChip(
            label: '${_dreams.length}',
            sub: 'total',
            color: AppTheme.auroraViolet,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: _filteredDreams.length.toString(),
            sub: 'shown',
            color: AppTheme.auroraTeal,
          ),
          if (topMood != null) ...[
            const SizedBox(width: 10),
            _StatChip(
              label: AppTheme.moodEmoji(topMood),
              sub: topMood,
              color: AppTheme.moodColor(topMood),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterMood != null)
            _FilterChip(
              label: '${AppTheme.moodEmoji(_filterMood!)} $_filterMood',
              onRemove: () => setState(() => _filterMood = null),
            ),
          if (_filterRange != null)
            _FilterChip(
              label:
                  '${_filterRange!.start.day}/${_filterRange!.start.month} – ${_filterRange!.end.day}/${_filterRange!.end.month}',
              onRemove: () => setState(() => _filterRange = null),
            ),
          if (_sortMode != SortMode.newest)
            _FilterChip(
              label: _sortMode == SortMode.oldest ? '↑ Oldest' : 'By Mood',
              onRemove: () => setState(() => _sortMode = SortMode.newest),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bg2,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.bedtime_outlined,
                size: 44, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          const Text(
            'The void awaits your dreams',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 17),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to record your first dream',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final h = DateTime.now().hour;
    if (h < 6) return 'still dreaming?';
    if (h < 12) return 'good morning, dreamer';
    if (h < 18) return 'afternoon reflection';
    return 'night is falling...';
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.auroraViolet.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _StatChip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 5),
          Text(sub,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.auroraViolet.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.auroraViolet.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.auroraViolet, fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13,
                color: AppTheme.auroraViolet),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
          if (badge)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.auroraTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _GlowFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.auroraViolet.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New Dream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final String? currentMood;
  final SortMode currentSort;
  final DateTimeRange? currentRange;
  final List<String> moods;
  final Function(String?, SortMode, DateTimeRange?) onApply;
  final VoidCallback onPickDate;

  const _FilterSheet({
    required this.currentMood,
    required this.currentSort,
    required this.currentRange,
    required this.moods,
    required this.onApply,
    required this.onPickDate,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _mood;
  late SortMode _sort;
  late DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _mood = widget.currentMood;
    _sort = widget.currentSort;
    _range = widget.currentRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Filter & Sort',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          const Text('SORT BY',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: SortMode.values.map((s) {
              final labels = ['Newest', 'Oldest', 'Mood'];
              final icons = [
                Icons.arrow_downward,
                Icons.arrow_upward,
                Icons.emoji_emotions_outlined
              ];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sort = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _sort == s
                          ? AppTheme.auroraViolet.withOpacity(0.2)
                          : AppTheme.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _sort == s
                            ? AppTheme.auroraViolet
                            : AppTheme.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icons[s.index],
                            color: _sort == s
                                ? AppTheme.auroraViolet
                                : AppTheme.textMuted,
                            size: 18),
                        const SizedBox(height: 4),
                        Text(labels[s.index],
                            style: TextStyle(
                              color: _sort == s
                                  ? AppTheme.auroraViolet
                                  : AppTheme.textMuted,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('MOOD',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () => setState(() => _mood = null),
                child: _MoodPill(
                    label: 'All',
                    emoji: '🌌',
                    color: AppTheme.textSecondary,
                    selected: _mood == null),
              ),
              ...widget.moods.map((m) => GestureDetector(
                    onTap: () => setState(() => _mood = m),
                    child: _MoodPill(
                        label: m,
                        emoji: AppTheme.moodEmoji(m),
                        color: AppTheme.moodColor(m),
                        selected: _mood == m),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          const Text('DATE RANGE',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              widget.onPickDate();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _range != null ? AppTheme.auroraTeal : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded,
                      color: _range != null
                          ? AppTheme.auroraTeal
                          : AppTheme.textMuted,
                      size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _range != null
                        ? '${_range!.start.day}/${_range!.start.month}/${_range!.start.year}  →  ${_range!.end.day}/${_range!.end.month}/${_range!.end.year}'
                        : 'Select date range',
                    style: TextStyle(
                      color: _range != null
                          ? AppTheme.auroraTeal
                          : AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  if (_range != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _range = null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppTheme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onApply(null, SortMode.newest, null);
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text('Reset',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => widget.onApply(_mood, _sort, _range),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.auroraViolet.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool selected;
  const _MoodPill(
      {required this.label,
      required this.emoji,
      required this.color,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: selected ? color : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
