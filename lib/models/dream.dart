class Dream {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String mood;

  Dream({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.mood,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'mood': mood,
    };
  }

  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      mood: map['mood'],
    );
  }

  Dream copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? mood,
  }) {
    return Dream(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      mood: mood ?? this.mood,
    );
  }
}
