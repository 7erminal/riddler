/// A bank card the owner has shared with another customer.
///
/// The owner creates a [CardShare] pointing at an invitee phone number.
/// The invitee sees it as a pending invitation, and once accepted the card
/// shows up among their accounts, visually marked as shared. The invitee
/// can request withdrawals from it, which the owner approves.
class CardShare {
  final String id;
  final String cardId;
  final String cardName;
  final String cardBankName;
  final String cardLast4;
  final String cardColor;
  final String ownerPhone;
  final String inviteePhone;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime createdAt;

  const CardShare({
    required this.id,
    required this.cardId,
    required this.cardName,
    required this.cardBankName,
    required this.cardLast4,
    required this.cardColor,
    required this.ownerPhone,
    required this.inviteePhone,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  CardShare copyWith({
    String? id,
    String? cardId,
    String? cardName,
    String? cardBankName,
    String? cardLast4,
    String? cardColor,
    String? ownerPhone,
    String? inviteePhone,
    String? status,
    DateTime? createdAt,
  }) {
    return CardShare(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      cardName: cardName ?? this.cardName,
      cardBankName: cardBankName ?? this.cardBankName,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardColor: cardColor ?? this.cardColor,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      inviteePhone: inviteePhone ?? this.inviteePhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CardShare.fromJson(Map<String, dynamic> json) => CardShare(
    id: json['id'] as String,
    cardId: json['cardId'] as String,
    cardName: json['cardName'] as String? ?? '',
    cardBankName: json['cardBankName'] as String? ?? '',
    cardLast4: json['cardLast4'] as String? ?? '',
    cardColor: json['cardColor'] as String? ?? 'mint',
    ownerPhone: json['ownerPhone'] as String,
    inviteePhone: json['inviteePhone'] as String,
    status: json['status'] as String? ?? 'pending',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'cardName': cardName,
    'cardBankName': cardBankName,
    'cardLast4': cardLast4,
    'cardColor': cardColor,
    'ownerPhone': ownerPhone,
    'inviteePhone': inviteePhone,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// A withdrawal from a shared card that is waiting for the card owner's
/// approval. Once the owner approves (with their PIN), the money moves from
/// the card into the requester's wallet.
class WithdrawalRequest {
  final String id;
  final String cardId;
  final String cardName;
  final String cardBankName;
  final String cardLast4;
  final String ownerPhone;
  final String requesterPhone;
  final double amount;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime createdAt;

  const WithdrawalRequest({
    required this.id,
    required this.cardId,
    required this.cardName,
    required this.cardBankName,
    required this.cardLast4,
    required this.ownerPhone,
    required this.requesterPhone,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  WithdrawalRequest copyWith({
    String? id,
    String? cardId,
    String? cardName,
    String? cardBankName,
    String? cardLast4,
    String? ownerPhone,
    String? requesterPhone,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return WithdrawalRequest(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      cardName: cardName ?? this.cardName,
      cardBankName: cardBankName ?? this.cardBankName,
      cardLast4: cardLast4 ?? this.cardLast4,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        id: json['id'] as String,
        cardId: json['cardId'] as String,
        cardName: json['cardName'] as String? ?? '',
        cardBankName: json['cardBankName'] as String? ?? '',
        cardLast4: json['cardLast4'] as String? ?? '',
        ownerPhone: json['ownerPhone'] as String,
        requesterPhone: json['requesterPhone'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'cardName': cardName,
    'cardBankName': cardBankName,
    'cardLast4': cardLast4,
    'ownerPhone': ownerPhone,
    'requesterPhone': requesterPhone,
    'amount': amount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}