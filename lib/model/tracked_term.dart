class TrackedTerm {
  final String term;
  final String id;
  bool locked;
  String? lastArticleHash;

  TrackedTerm({
    required this.term,
    required this.id,
    this.locked = false,
    this.lastArticleHash,
  });

  TrackedTerm copyWith({
    String? term,
    String? id,
    bool? locked,
    String? lastArticleHash,
  }) {
    return TrackedTerm(
      term: term ?? this.term,
      id: id ?? this.id,
      locked: locked ?? this.locked,
      lastArticleHash: lastArticleHash ?? this.lastArticleHash,
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
}
