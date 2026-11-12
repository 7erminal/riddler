/// A bill being split between several people.
///
/// Splitting is still in early development, so this only plans the split
/// (who owes what) and stores it. Moving money between the people comes
/// later.
class SplitPayment {
  final String id;
  final String title;
  final double total;
  final List<SplitPerson> people;
  final DateTime createdAt;

  const SplitPayment({
    required this.id,
    required this.title,
    required this.total,
    required this.people,
    required this.createdAt,
  });

  /// Each person's equal share of the bill.
  double get sharePerPerson =>
      people.isEmpty ? 0 : double.parse((total / people.length).toStringAsFixed(2));

  factory SplitPayment.fromJson(Map<String, dynamic> json) => SplitPayment(
    id: json['id'] as String,
    title: json['title'] as String,
    total: (json['total'] as num).toDouble(),
    people: (json['people'] as List<dynamic>? ?? [])
        .map((e) => SplitPerson.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'total': total,
    'people': people.map((p) => p.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}

/// A person taking part in a [SplitPayment].
class SplitPerson {
  final String name;
  final double share;

  const SplitPerson({required this.name, required this.share});

  factory SplitPerson.fromJson(Map<String, dynamic> json) => SplitPerson(
    name: json['name'] as String,
    share: (json['share'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'share': share};
}
