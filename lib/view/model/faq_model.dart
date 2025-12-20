// models/faq_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQ {
  String id;
  String question;
  String answer;
  DateTime createdAt;
  DateTime? updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    this.updatedAt,
  });

  factory FAQ.fromMap(Map<String, dynamic> map) {
    return FAQ(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'question': question,
      'answer': answer,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}