import 'package:flutter/material.dart';

class TrackedTerm {
  final String term;
  final int notificationId;
  final String id;
  final bool locked;
  final String? lastPublishedAt;
  final TimeOfDay? notificationTime;

  TrackedTerm({
    required this.term,
    required this.notificationId,
    required this.id,
    this.locked = false,
    this.lastPublishedAt,
    this.notificationTime,
  });

  TrackedTerm copyWith({
    String? term,
    int? notificationId,
    String? id,
    bool? locked,
    String? lastPublishedAt,
    TimeOfDay? notificationTime,
  }) {
    return TrackedTerm(
      term: term ?? this.term,
      notificationId: notificationId ?? this.notificationId,
      id: id ?? this.id,
      locked: locked ?? this.locked,
      lastPublishedAt: lastPublishedAt ?? this.lastPublishedAt,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  factory TrackedTerm.fromJson(Map<String, dynamic> json) {
    return TrackedTerm(
      term: json['term'],
      notificationId: json['notificationId'],
      id: json['id'],
      locked: json['locked'] ?? false,
      notificationTime: json['notificationTime'] != null
          ? TimeOfDay(
              hour: json['notificationTime']['hour'],
              minute: json['notificationTime']['minute'],
            )
          : null,
      lastPublishedAt: json['lastArticleHash'],
    );
  }

  Map<String, dynamic> toJson() => {
    'term': term,
    'notificationId': notificationId,
    'id': id,
    'locked': locked,
    'notificationTime': notificationTime != null
        ? {'hour': notificationTime!.hour, 'minute': notificationTime!.minute}
        : null,
    'lastArticleHash': lastPublishedAt,
  };
}
