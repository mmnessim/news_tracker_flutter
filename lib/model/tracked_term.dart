class TrackedTerm {
  final String term;
  final int id;

  TrackedTerm({required this.term, required this.id});

  TrackedTerm copyWith({String? term, int? id}) =>
      TrackedTerm(term: term ?? this.term, id: id ?? this.id);
}
