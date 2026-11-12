/// A money request sent to another customer.
///
/// In real life the request is delivered as a link (see [link]); the payee
/// opens it, confirms and authorises with their PIN, and money moves between
/// bank accounts. Locally the request list simulates both sides until a
/// backend is wired up.
class MoneyRequest {
  final String id;
  final String requesterNumber; // who is asking for the money
  final String requesterName;
  final String payerNumber; // who is being asked (the target entered)
  final double amount;
  final String note;
  final String status; // 'pending' | 'paid' | 'declined'
  final DateTime createdAt;

  const MoneyRequest({
    required this.id,
    required this.requesterNumber,
    required this.requesterName,
    required this.payerNumber,
    required this.amount,
    this.note = '',
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';

  /// Shareable deep link that would be sent to the payee.
  String get link => 'ridlers://pay/$id';

  MoneyRequest copyWith({
    String? id,
    String? requesterNumber,
    String? requesterName,
    String? payerNumber,
    double? amount,
    String? note,
    String? status,
    DateTime? createdAt,
  }) {
    return MoneyRequest(
      id: id ?? this.id,
      requesterNumber: requesterNumber ?? this.requesterNumber,
      requesterName: requesterName ?? this.requesterName,
      payerNumber: payerNumber ?? this.payerNumber,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MoneyRequest.fromJson(Map<String, dynamic> json) => MoneyRequest(
    id: json['id'] as String,
    requesterNumber: json['requesterNumber'] as String,
    requesterName: json['requesterName'] as String? ?? '',
    payerNumber: json['payerNumber'] as String,
    amount: (json['amount'] as num).toDouble(),
    note: json['note'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'requesterNumber': requesterNumber,
    'requesterName': requesterName,
    'payerNumber': payerNumber,
    'amount': amount,
    'note': note,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
