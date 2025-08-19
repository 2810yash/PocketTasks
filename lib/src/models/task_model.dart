class Task {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    done: json['done'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  String toString() {
    return 'Task(id: ' + id + ', title: ' + title + ', done: ' + done.toString() + ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.done == done &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ done.hashCode ^ createdAt.hashCode;
  }
}