class Dream {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String mood;
  final List<String> tags;

  Dream({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.mood,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'mood': mood,
      'tags': tags,
    };
  }

  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      mood: map['mood'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Dream copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? mood,
    List<String>? tags,
  }) {
    return Dream(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
    );
  }
}
