import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../widgets/dream_card.dart';
import 'add_dream_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Dream> _dreams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final dreams = await DreamStorage.getDreams();
    setState(() {
      _dreams = dreams;
      _loading = false;
    });
  }

  Future<void> _deleteDream(String id) async {
    await DreamStorage.deleteDream(id);
    _loadDreams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nightlight_round, color: Color(0xFF7C6FF7), size: 22),
            SizedBox(width: 8),
            Text('Dream Journal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF9B89FF)),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
              _loadDreams();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6FF7)))
          : _dreams.isEmpty
              ? _buildEmpty()
              : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddDreamScreen()));
          _loadDreams();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Dream'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime_outlined,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            'No dreams recorded yet',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to record your first dream',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dreams.length,
      itemBuilder: (context, index) {
        return DreamCard(
          dream: _dreams[index],
          onDelete: () => _deleteDream(_dreams[index].id),
          onRefresh: _loadDreams,
        );
      },
    );
  }
}
