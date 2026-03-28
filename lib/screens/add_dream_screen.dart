import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';

class AddDreamScreen extends StatefulWidget {
  final Dream? dream;
  const AddDreamScreen({super.key, this.dream});

  @override
  State<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Peaceful';

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy', 'emoji': '😊', 'color': Color(0xFFFFD700)},
    {'label': 'Scary', 'emoji': '😨', 'color': Color(0xFFFF4444)},
    {'label': 'Weird', 'emoji': '🤔', 'color': Color(0xFFFF8C00)},
    {'label': 'Peaceful', 'emoji': '😌', 'color': Color(0xFF4CAF50)},
    {'label': 'Neutral', 'emoji': '😐', 'color': Color(0xFF9E9E9E)},
  ];

  bool get isEditing => widget.dream != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.dream!.title;
      _descController.text = widget.dream!.description;
      _selectedDate = widget.dream!.date;
      _selectedMood = widget.dream!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
            primary: Color(0xFF7C6FF7),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a dream title')),
      );
      return;
    }

    if (isEditing) {
      final updated = widget.dream!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        mood: _selectedMood,
      );
      await DreamStorage.updateDream(updated);
    } else {
      final dream = Dream(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        mood: _selectedMood,
      );
      await DreamStorage.saveDream(dream);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Dream' : 'New Dream'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Dream Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'What was your dream about?',
                prefixIcon: Icon(Icons.title, color: Color(0xFF7C6FF7)),
              ),
            ),
            const SizedBox(height: 20),
            _label('Dream Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Describe your dream in detail...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.notes, color: Color(0xFF7C6FF7)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A5C)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF7C6FF7), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF9B89FF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Mood'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['label']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (mood['color'] as Color).withOpacity(0.2)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? mood['color'] as Color
                            : const Color(0xFF3A3A5C),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood['emoji'], style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            color: isSelected
                                ? mood['color'] as Color
                                : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FF7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Dream',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9B89FF),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 
