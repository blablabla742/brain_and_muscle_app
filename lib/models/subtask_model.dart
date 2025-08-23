class Subtask {
  final String title;
  final bool isDone;

  Subtask({required this.title, required this.isDone});

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(title: map['title'] ?? '', isDone: map['isDone'] ?? false);
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isDone': isDone};
  }

  Subtask copyWith({String? title, bool? isDone}) {
    return Subtask(title: title ?? this.title, isDone: isDone ?? this.isDone);
  }
}
