import 'package:flutter/material.dart';

class TrackedTerm {
  final String term;
  final String id;
  final bool locked;
  final String? lastArticleHash;
  final TimeOfDay? notificationTime;

  TrackedTerm({
    required this.term,
    required this.id,
    this.locked = false,
    this.lastArticleHash,
    this.notificationTime,
  });

  TrackedTerm copyWith({
    String? term,
    String? id,
    bool? locked,
    String? lastArticleHash,
    TimeOfDay? notificationTime,
  }) {
    return TrackedTerm(
      term: term ?? this.term,
      id: id ?? this.id,
      locked: locked ?? this.locked,
      lastArticleHash: lastArticleHash ?? this.lastArticleHash,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  factory TrackedTerm.fromJson(Map<String, dynamic> json) {
    return TrackedTerm(
      term: json['term'],
      id: json['id'],
      locked: json['locked'] ?? false,
      lastArticleHash: json['lastArticleHash'],
    );
  }

  Map<String, dynamic> toJson() => {
    'term': term,
    'id': id,
    'locked': locked,
    'lastArticleHash': lastArticleHash,
  };
}
