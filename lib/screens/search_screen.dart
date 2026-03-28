import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../services/dream_storage.dart';
import '../widgets/dream_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Dream> _allDreams = [];
  List<Dream> _results = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearch);
  }

  Future<void> _load() async {
    final dreams = await DreamStorage.getDreams();
    setState(() {
      _allDreams = dreams;
      _results = dreams;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _results = _allDreams.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.mood.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Dreams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search by title, mood, or keyword...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF7C6FF7)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_results.length} dream${_results.length != 1 ? 's' : ''} found',
                  style: const TextStyle(color: Color(0xFF9B89FF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text('No dreams found',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
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
    );
  }
}
