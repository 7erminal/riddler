/// A record of a banking service action (transfer, airtime, data, request).
///
/// Kept separate from [WalletTransaction] because these operations happen
/// on the attached bank cards directly, with no wallet involvement.
class ActivityRecord {
  final String id;
  final String kind; // 'transfer' | 'airtime' | 'data' | 'request' | 'split'
  final String title;
  final String subtitle;
  final double amount;
  final String type; // 'out' | 'in'
  final DateTime createdAt;

  const ActivityRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  bool get isOut => type == 'out';

  factory ActivityRecord.fromJson(Map<String, dynamic> json) => ActivityRecord(
    id: json['id'] as String,
    kind: json['kind'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    amount: (json['amount'] as num).toDouble(),
    type: json['type'] as String? ?? 'out',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'subtitle': subtitle,
    'amount': amount,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
  };
}
