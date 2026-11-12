/// A single deposit of money from an attached bank card into a wallet.
///
/// Every time money is pulled from a card into a wallet (via
/// [WalletService.transferFromCard] or [WalletService.withdrawFromCard]) a
/// record is kept here so that, when the wallet gets deleted, its remaining
/// balance can be funded back to the exact cards it came from.
class WalletDeposit {
  final String id;
  final String walletId;
  final String cardId;
  final String cardName;
  final double amount;
  final DateTime createdAt;

  const WalletDeposit({
    required this.id,
    required this.walletId,
    required this.cardId,
    required this.cardName,
    required this.amount,
    required this.createdAt,
  });

  WalletDeposit copyWith({
    String? id,
    String? walletId,
    String? cardId,
    String? cardName,
    double? amount,
    DateTime? createdAt,
  }) {
    return WalletDeposit(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      cardId: cardId ?? this.cardId,
      cardName: cardName ?? this.cardName,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WalletDeposit.fromJson(Map<String, dynamic> json) => WalletDeposit(
    id: json['id'] as String,
    walletId: json['walletId'] as String,
    cardId: json['cardId'] as String,
    cardName: json['cardName'] as String? ?? '',
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'cardId': cardId,
    'cardName': cardName,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };
}