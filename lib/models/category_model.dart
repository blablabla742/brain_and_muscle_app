import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final DateTime createdAt;
  final int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.colorValue,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      colorValue: data['colorValue'] ?? 0xFF2196F3, // Standardfarbe Blau
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'colorValue': colorValue,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
