/// A bank card attached to the user's Ridlers wallet.
///
/// Balance is tracked locally: every transfer out of the card into the
/// wallet reduces this [balance] by the transferred amount.
class BankCard {
  final String id;
  final String bankName;
  final String nickname;
  final String cardNumber;
  final double balance;
  final String color;
  final bool isPrimary;
  final bool isShared;
  final DateTime createdAt;

  const BankCard({
    required this.id,
    required this.bankName,
    required this.nickname,
    required this.cardNumber,
    required this.balance,
    required this.color,
    this.isPrimary = false,
    this.isShared = false,
    required this.createdAt,
  });

  String get last4 => cardNumber.length >= 4
      ? cardNumber.substring(cardNumber.length - 4)
      : cardNumber;

  String get maskedNumber => '••••  ••••  ••••  $last4';

  BankCard copyWith({
    String? id,
    String? bankName,
    String? nickname,
    String? cardNumber,
    double? balance,
    String? color,
    bool? isPrimary,
    bool? isShared,
    DateTime? createdAt,
  }) {
    return BankCard(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      nickname: nickname ?? this.nickname,
      cardNumber: cardNumber ?? this.cardNumber,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      isPrimary: isPrimary ?? this.isPrimary,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard(
    id: json['id'] as String,
    bankName: json['bankName'] as String,
    nickname: json['nickname'] as String,
    cardNumber: json['cardNumber'] as String,
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    color: json['color'] as String? ?? 'mint',
    isPrimary: json['isPrimary'] as bool? ?? false,
    isShared: json['isShared'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bankName': bankName,
    'nickname': nickname,
    'cardNumber': cardNumber,
    'balance': balance,
    'color': color,
    'isPrimary': isPrimary,
    'isShared': isShared,
    'createdAt': createdAt.toIso8601String(),
  };
}
