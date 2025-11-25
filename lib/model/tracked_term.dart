import 'package:flutter/material.dart';

class TrackedTerm {
  final String term;
  final int notificationId;
  final String id;
  final bool locked;
  final String? lastArticleHash;
  final TimeOfDay? notificationTime;

  TrackedTerm({
    required this.term,
    required this.notificationId,
    required this.id,
    this.locked = false,
    this.lastArticleHash,
    this.notificationTime,
  });

  TrackedTerm copyWith({
    String? term,
    int? notificationId,
    String? id,
    bool? locked,
    String? lastArticleHash,
    TimeOfDay? notificationTime,
  }) {
    return TrackedTerm(
      term: term ?? this.term,
      notificationId: notificationId ?? this.notificationId,
      id: id ?? this.id,
      locked: locked ?? this.locked,
      lastArticleHash: lastArticleHash ?? this.lastArticleHash,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  factory TrackedTerm.fromJson(Map<String, dynamic> json) {
    return TrackedTerm(
      term: json['term'],
      notificationId: json['notificationId'],
      id: json['id'],
      locked: json['locked'] ?? false,
      lastArticleHash: json['lastArticleHash'],
    );
  }

  Map<String, dynamic> toJson() => {
    'term': term,
    'notificationId': notificationId,
    'id': id,
    'locked': locked,
    'lastArticleHash': lastArticleHash,
  };
}
