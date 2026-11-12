import 'package:ridlers/infrastructure/models/walletModel.dart';

/// A member invited to a group wallet.
/// Members are identified by phone number. The [status] tracks whether
/// they have confirmed or rejected the invitation. Once accepted, the
/// member gains shared access to the group wallet.
class GroupMember {
  final String id;
  final String phone;
  final String name;
  final String role; // 'owner' | 'admin' | 'member'
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime? joinedAt;

  const GroupMember({
    required this.id,
    required this.phone,
    this.name = '',
    this.role = 'member',
    this.status = 'pending',
    this.joinedAt,
  });

  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isOwner => role == 'owner';

  GroupMember copyWith({
    String? id,
    String? phone,
    String? name,
    String? role,
    String? status,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'] as String,
    phone: json['phone'] as String,
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? 'member',
    status: json['status'] as String? ?? 'pending',
    joinedAt: json['joinedAt'] != null
        ? DateTime.parse(json['joinedAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'name': name,
    'role': role,
    'status': status,
    'joinedAt': joinedAt?.toIso8601String(),
  };
}

/// A wallet owned by multiple people.
///
/// Group wallets work like regular wallets (with sub-wallets, deposits,
/// withdrawals) but access is shared among [members] who have accepted
/// the invitation. Only the [ownerId] can delete the wallet or manage
/// members.
class GroupWallet {
  final String id;
  final String name;
  final String color;
  final String ownerId;
  final List<GroupMember> members;
  final List<SubWallet> subWallets;
  final double totalBalance;
  final DateTime createdAt;

  /// How deposits are split across pockets: `'percent'` or `'figures'`.
  final String splitMode;

  const GroupWallet({
    required this.id,
    required this.name,
    this.color = 'mint',
    required this.ownerId,
    this.members = const [],
    this.subWallets = const [],
    this.totalBalance = 0,
    this.splitMode = 'percent',
    required this.createdAt,
  });

  double get allocatedPercent =>
      subWallets.fold(0, (s, w) => s + w.percentage);

  double get remainingPercent => (100 - allocatedPercent).clamp(0, 100);

  double get mainBalance =>
      subWallets.fold(totalBalance, (s, w) => s - w.balance);

  List<GroupMember> get acceptedMembers =>
      members.where((m) => m.isAccepted).toList();

  List<GroupMember> get pendingMembers =>
      members.where((m) => m.isPending).toList();

  int get memberCount => members.length;

  GroupWallet copyWith({
    String? id,
    String? name,
    String? color,
    String? ownerId,
    List<GroupMember>? members,
    List<SubWallet>? subWallets,
    double? totalBalance,
    String? splitMode,
    DateTime? createdAt,
  }) {
    return GroupWallet(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      subWallets: subWallets ?? this.subWallets,
      totalBalance: totalBalance ?? this.totalBalance,
      splitMode: splitMode ?? this.splitMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory GroupWallet.fromJson(Map<String, dynamic> json) => GroupWallet(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Group Wallet',
    color: json['color'] as String? ?? 'mint',
    ownerId: json['ownerId'] as String,
    members: (json['members'] as List<dynamic>? ?? [])
        .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
        .toList(),
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
    'ownerId': ownerId,
    'members': members.map((m) => m.toJson()).toList(),
    'subWallets': subWallets.map((w) => w.toJson()).toList(),
    'totalBalance': totalBalance,
    'splitMode': splitMode,
    'createdAt': createdAt.toIso8601String(),
  };
}
