import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String text;
  bool completed;
  final String priority;
  final DateTime createdAt;
  final String userId;
  final String createdBy;
  final List<String> sharedWith;
  final bool isShared;
  final String? category;

  Todo({
    required this.id,
    required this.text,
    this.completed = false,
    required this.priority,
    required this.createdAt,
    required this.userId,
    required this.createdBy,
    this.sharedWith = const [],
    this.isShared = false,
    this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'completed': completed,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'createdBy': createdBy,
      'sharedWith': sharedWith,
      'isShared': isShared,
      'category': category,
    };
  }

  static Todo fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      text: data['text'] ?? '',
      completed: data['completed'] ?? false,
      priority: data['priority'] ?? 'medium',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      isShared: data['isShared'] ?? false,
      category: data['category'],
    );
  }

  Todo copyWith({
    String? id,
    String? text,
    bool? completed,
    String? priority,
    DateTime? createdAt,
    String? userId,
    String? createdBy,
    List<String>? sharedWith,
    bool? isShared,
    String? category,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? this.sharedWith,
      isShared: isShared ?? this.isShared,
      category: category ?? this.category,
    );
  }
}