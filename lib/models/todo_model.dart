import 'package:cloud_firestore/cloud_firestore.dart';

import 'subtask_model.dart';

class Todo {
  final String id;
  final String title;
  final String? description;
  final String? assignedTo; // User ID or external person name
  final String categoryId;
  final bool isDone;
  final DateTime? dueDate;
  final bool isRecurring;
  final String status;
  final List<Subtask> subtasks;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.assignedTo,
    required this.categoryId,
    this.isDone = false,
    this.dueDate,
    this.isRecurring = false,
    this.status = 'offen',
    this.subtasks = const [],
  });

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      assignedTo: data['assignedTo'],
      categoryId: data['categoryId'] ?? '',
      isDone: data['isDone'] ?? false,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isRecurring: data['isRecurring'] ?? false,
      status: data['status'] ?? 'offen',
      subtasks:
          (data['subtasks'] as List<dynamic>?)
              ?.map((item) => Subtask.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'categoryId': categoryId,
      'isDone': isDone,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isRecurring': isRecurring,
      'status': status,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? categoryId,
    bool? isDone,
    DateTime? dueDate,
    bool? isRecurring,
    String? status,
    List<Subtask>? subtasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      categoryId: categoryId ?? this.categoryId,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      status: status ?? this.status,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
