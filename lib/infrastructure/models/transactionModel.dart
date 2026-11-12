/// A record of money flowing in or out of the wallet.
class WalletTransaction {
  final String id;
  final String walletId;
  final String type; // 'in' | 'out'
  final double amount;
  final String? cardId;
  final String? cardName;
  final String? destinationType; // 'card' | 'momo' when money goes out
  final String? destinationName;
  final String? destinationNumber;
  final String note;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.cardId,
    this.cardName,
    this.destinationType,
    this.destinationName,
    this.destinationNumber,
    this.note = '',
    required this.createdAt,
  });

  bool get isDeposit => type == 'in';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        walletId: json['walletId'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        cardId: json['cardId'] as String?,
        cardName: json['cardName'] as String?,
        destinationType: json['destinationType'] as String?,
        destinationName: json['destinationName'] as String?,
        destinationNumber: json['destinationNumber'] as String?,
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'type': type,
    'amount': amount,
    'cardId': cardId,
    'cardName': cardName,
    'destinationType': destinationType,
    'destinationName': destinationName,
    'destinationNumber': destinationNumber,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };
}
