/// A named pocket inside the Ridlers wallet.
///
/// Each sub-wallet claims a fixed [percentage] of every deposit into the
/// wallet. The percentages of all sub-wallets combined can never exceed
/// 100%; whatever is left is kept by the wallet itself (the "main" pocket).
class SubWallet {
  final String id;
  final String title;
  final String purpose;
  final double percentage;
  final String color;
  final double balance;
  final DateTime createdAt;

  /// Target amount for this pocket when the wallet splits by figures.
  /// `null` when the wallet splits by percentage.
  final double? allocation;

  /// Rank used when the wallet splits by figures. `1` is the highest
  /// priority: deposits fill this pocket before any lower-ranked pocket.
  final int priority;

  const SubWallet({
    required this.id,
    required this.title,
    required this.purpose,
    required this.percentage,
    required this.color,
    this.balance = 0,
    this.allocation,
    this.priority = 1,
    required this.createdAt,
  });

  SubWallet copyWith({
    String? id,
    String? title,
    String? purpose,
    double? percentage,
    String? color,
    double? balance,
    double? allocation,
    int? priority,
    DateTime? createdAt,
  }) {
    return SubWallet(
      id: id ?? this.id,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      allocation: allocation ?? this.allocation,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Amount this pocket receives out of a [deposit] in percentage mode.
  double shareOf(double deposit) => deposit * percentage / 100;

  factory SubWallet.fromJson(Map<String, dynamic> json) => SubWallet(
    id: json['id'] as String,
    title: json['title'] as String,
    purpose: json['purpose'] as String? ?? '',
    percentage: (json['percentage'] as num).toDouble(),
    color: json['color'] as String? ?? 'mint',
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    allocation: (json['allocation'] as num?)?.toDouble(),
    priority: json['priority'] as int? ?? 1,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'purpose': purpose,
    'percentage': percentage,
    'color': color,
    'balance': balance,
    'allocation': allocation,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// The user's main wallet.
///
/// Every deposit is split across [subWallets] by their percentages; the
/// remainder stays in the wallet itself and is reported as [mainBalance].
/// A user can hold several of these, each with its own pockets.
class Wallet {
  final String id;
  final String name;
  final String color;
  final List<SubWallet> subWallets;
  final double totalBalance;
  final DateTime createdAt;

  /// How deposits are split across pockets: `'percent'` (each pocket takes
  /// a fixed percentage) or `'figures'` (each pocket takes a set amount,
  /// filled in priority order).
  final String splitMode;

  const Wallet({
    required this.id,
    required this.name,
    this.color = 'mint',
    this.subWallets = const [],
    this.totalBalance = 0,
    this.splitMode = 'percent',
    required this.createdAt,
  });

  /// Sum of all sub-wallet percentages.
  double get allocatedPercent => subWallets.fold(0, (s, w) => s + w.percentage);

  /// What stays with the wallet itself.
  double get remainingPercent => (100 - allocatedPercent).clamp(0, 100);

  /// Money still sitting in the main wallet pocket (the un-allocated share).
  double get mainBalance =>
      subWallets.fold(totalBalance, (s, w) => s - w.balance);

  Wallet copyWith({
    String? id,
    String? name,
    String? color,
    List<SubWallet>? subWallets,
    double? totalBalance,
    String? splitMode,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      subWallets: subWallets ?? this.subWallets,
      totalBalance: totalBalance ?? this.totalBalance,
      splitMode: splitMode ?? this.splitMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'My Wallet',
    color: json['color'] as String? ?? 'mint',
    subWallets: (json['subWallets'] as List<dynamic>? ?? [])
        .map((e) => SubWallet.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
    splitMode: json['splitMode'] as String? ?? 'percent',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'subWallets': subWallets.map((w) => w.toJson()).toList(),
    'totalBalance': totalBalance,
    'splitMode': splitMode,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// A resolved wallet payment source: which wallet and optionally which pocket.
class WalletPaymentSource {
  final String walletId;
  final String walletName;
  final String? subWalletId;
  final String? subWalletTitle;
  final double available;

  const WalletPaymentSource({
    required this.walletId,
    required this.walletName,
    this.subWalletId,
    this.subWalletTitle,
    required this.available,
  });

  String get label => subWalletId == null ? '$walletName › Main' : '$walletName › $subWalletTitle';
}
