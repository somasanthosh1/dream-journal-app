import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../theme/app_theme.dart';

class AddDreamScreen extends StatefulWidget {
  final Dream? dream;
  const AddDreamScreen({super.key, this.dream});

  @override
  State<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Peaceful';
  List<String> _tags = [];

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy',   'emoji': '✨', 'color': AppTheme.auroraGold},
    {'label': 'Scary',   'emoji': '🌑', 'color': Color(0xFFEF4444)},
    {'label': 'Weird',   'emoji': '🌀', 'color': Color(0xFFA855F7)},
    {'label': 'Peaceful','emoji': '🌊', 'color': AppTheme.auroraTeal},
    {'label': 'Lucid',   'emoji': '💎', 'color': AppTheme.auroraBlue},
    {'label': 'Neutral', 'emoji': '🌫️','color': Color(0xFF6B7280)},
  ];

  bool get isEditing => widget.dream != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleCtrl.text = widget.dream!.title;
      _descCtrl.text = widget.dream!.description;
      _selectedDate = widget.dream!.date;
      _selectedMood = widget.dream!.mood;
      _tags = List.from(widget.dream!.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _addTag(String tag) {
    final t = tag.trim().replaceAll('#', '').toLowerCase();
    if (t.isNotEmpty && !_tags.contains(t) && _tags.length < 5) {
      setState(() => _tags.add(t));
      _tagCtrl.clear();
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a dream title');
      return;
    }

    if (isEditing) {
      final updated = widget.dream!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
        mood: _selectedMood,
        tags: _tags,
      );
      await DreamStorage.updateDream(updated);
    } else {
      final dream = Dream(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
        mood: _selectedMood,
        tags: _tags,
      );
      await DreamStorage.saveDream(dream);
    }
    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.auroraViolet.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
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
                      Text(
                        isEditing ? 'Edit Dream' : 'New Dream',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
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
                        _label('DREAM TITLE'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleCtrl,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'What was your dream about?',
                            prefixIcon: const Icon(Icons.auto_awesome,
                                color: AppTheme.auroraViolet, size: 18),
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
                        const SizedBox(height: 20),
                        _label('DESCRIPTION'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descCtrl,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 15),
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Describe your dream in detail...',
                            alignLabelWithHint: true,
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
                        const SizedBox(height: 20),

                        // Date & Mood side by side
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('DATE'),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 13),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bg2,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_month_rounded,
                                              color: AppTheme.auroraTeal, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                              style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 14),
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

                        const SizedBox(height: 20),
                        _label('MOOD'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _moods.map((m) {
                            final isSelected = _selectedMood == m['label'];
                            final color = m['color'] as Color;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMood = m['label']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.15)
                                      : AppTheme.bg2,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        isSelected ? color : AppTheme.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.2),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(m['emoji'],
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      m['label'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? color
                                            : AppTheme.textMuted,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        _label('TAGS  (optional, max 5)'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagCtrl,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 14),
                                onSubmitted: _addTag,
                                decoration: InputDecoration(
                                  hintText: 'flying, forest, water...',
                                  prefixText: '# ',
                                  prefixStyle: const TextStyle(
                                      color: AppTheme.textMuted),
                                  filled: true,
                                  fillColor: AppTheme.bg2,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: AppTheme.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: AppTheme.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: AppTheme.auroraViolet, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _addTag(_tagCtrl.text),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.auroraViolet.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.auroraViolet.withOpacity(0.4)),
                                ),
                                child: const Icon(Icons.add,
                                    color: AppTheme.auroraViolet, size: 20),
                              ),
                            ),
                          ],
                        ),
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.auroraViolet
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.auroraViolet
                                                .withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('#$t',
                                              style: const TextStyle(
                                                  color: AppTheme.auroraViolet,
                                                  fontSize: 12)),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => setState(
                                                () => _tags.remove(t)),
                                            child: const Icon(Icons.close,
                                                size: 13,
                                                color: AppTheme.auroraViolet),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],

                        const SizedBox(height: 36),
                        GestureDetector(
                          onTap: _save,
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.auroraViolet.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  isEditing ? 'Update Dream' : 'Save Dream',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

