import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dream.dart';

class DreamStorage {
  static final _collection =
      FirebaseFirestore.instance.collection('dreams');

  static Future<List<Dream>> getDreams() async {
    final snapshot = await _collection
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Dream.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  static Future<void> saveDream(Dream dream) async {
    await _collection.add({
      'title': dream.title,
      'description': dream.description,
      'date': dream.date.toIso8601String(),
      'mood': dream.mood,
    });
  }

  static Future<void> updateDream(Dream dream) async {
    await _collection.doc(dream.id).update({
      'title': dream.title,
      'description': dream.description,
      'date': dream.date.toIso8601String(),
      'mood': dream.mood,
    });
  }

  static Future<void> deleteDream(String id) async {
    await _collection.doc(id).delete();
  }
}
