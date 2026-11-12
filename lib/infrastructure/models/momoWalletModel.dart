/// A mobile money wallet the user can withdraw into.
class MoMoWallet {
  final String id;
  final String provider;
  final String name;
  final String number;
  final String color;
  final DateTime createdAt;

  const MoMoWallet({
    required this.id,
    required this.provider,
    required this.name,
    required this.number,
    required this.color,
    required this.createdAt,
  });

  MoMoWallet copyWith({
    String? id,
    String? provider,
    String? name,
    String? number,
    String? color,
    DateTime? createdAt,
  }) {
    return MoMoWallet(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      name: name ?? this.name,
      number: number ?? this.number,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MoMoWallet.fromJson(Map<String, dynamic> json) => MoMoWallet(
    id: json['id'] as String,
    provider: json['provider'] as String? ?? 'MTN',
    name: json['name'] as String? ?? json['provider']?.toString() ?? 'Mobile Money',
    number: json['number'] as String,
    color: json['color'] as String? ?? 'yellow',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider,
    'name': name,
    'number': number,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
  };
}

const List<String> momoProviders = ['MTN', 'Telecel', 'AT'];
