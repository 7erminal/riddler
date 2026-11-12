import 'package:ridlers/index.dart';

/// Business logic for group wallets.
///
/// All mutations are persisted locally through [StorageService]. When the
/// backend is ready, each method also calls the corresponding
/// [GroupWalletApi] endpoint.
class GroupWalletService {
  GroupWalletService(this.bloc);

  final WalletBloc bloc;

  /// Hydrates the bloc from local storage.
  Future<void> load() async {
    bloc.setGroupWallets(await StorageService.loadGroupWallets());
  }

  /// Creates a new group wallet with the given [name], [color], and
  /// list of [memberPhones]. The current user becomes the owner and is
  /// auto-accepted.
  Future<GroupWallet> createGroupWallet({
    required String name,
    required String color,
    required List<String> memberPhones,
    String splitMode = 'percent',
  }) async {
    final ownerPhone = systemBloc.phone;

    final members = <GroupMember>[
      GroupMember(
        id: Functions.generateId(),
        phone: ownerPhone,
        name: systemBloc.displayName,
        role: 'owner',
        status: 'accepted',
        joinedAt: DateTime.now(),
      ),
      for (final phone in memberPhones)
        GroupMember(
          id: Functions.generateId(),
          phone: phone,
          role: 'member',
          status: 'pending',
        ),
    ];

    final wallet = GroupWallet(
      id: Functions.generateId(),
      name: name.trim().isEmpty ? 'Group Wallet' : name.trim(),
      color: color,
      ownerId: ownerPhone,
      members: members,
      splitMode: splitMode,
      createdAt: DateTime.now(),
    );

    final wallets = [...bloc.groupWallets, wallet];
    await _persist(wallets);

    // TODO: Call GroupWalletApi.createGroupWallet(...) when backend is ready.

    return wallet;
  }

  /// The current user accepts the invitation to [walletId].
  Future<void> acceptInvite(String walletId) async {
    final wallet = bloc.groupWalletById(walletId);
    if (wallet == null) return;

    final phone = systemBloc.phone;
    final members = wallet.members.map((m) {
      if (m.phone == phone && m.isPending) {
        return m.copyWith(
          status: 'accepted',
          joinedAt: DateTime.now(),
          name: m.name.isEmpty ? systemBloc.displayName : m.name,
        );
      }
      return m;
    }).toList();

    final updated = wallet.copyWith(members: members);
    final wallets = bloc.groupWallets
        .map((w) => w.id == walletId ? updated : w)
        .toList();
    await _persist(wallets);

    // TODO: Call GroupWalletApi.acceptInvite(...) when backend is ready.
  }

  /// The current user rejects the invitation to [walletId].
  Future<void> rejectInvite(String walletId) async {
    final wallet = bloc.groupWalletById(walletId);
    if (wallet == null) return;

    final phone = systemBloc.phone;
    final members = wallet.members.map((m) {
      if (m.phone == phone && m.isPending) {
        return m.copyWith(status: 'rejected');
      }
      return m;
    }).toList();

    final updated = wallet.copyWith(members: members);
    final wallets = bloc.groupWallets
        .map((w) => w.id == walletId ? updated : w)
        .toList();
    await _persist(wallets);

    // TODO: Call GroupWalletApi.rejectInvite(...) when backend is ready.
  }

  /// The owner adds a new member by [phone] to [walletId]. Returns `false`
  /// when the phone is invalid, already in the wallet, or belongs to the
  /// owner.
  Future<bool> addMember(String walletId, String phone) async {
    final wallet = bloc.groupWalletById(walletId);
    if (wallet == null) return false;

    final clean = phone.replaceAll(' ', '').trim();
    if (clean.length < 9) return false;
    if (clean == wallet.ownerId) return false;
    if (wallet.members.any((m) => m.phone == clean)) return false;

    final member = GroupMember(
      id: Functions.generateId(),
      phone: clean,
      role: 'member',
      status: 'pending',
    );

    final updated = wallet.copyWith(
      members: [...wallet.members, member],
    );
    final wallets = bloc.groupWallets
        .map((w) => w.id == walletId ? updated : w)
        .toList();
    await _persist(wallets);

    // TODO: Call GroupWalletApi.inviteMember(...) when backend is ready.
    return true;
  }

  /// The owner removes a member from [walletId].
  Future<void> removeMember(String walletId, String memberId) async {
    final wallet = bloc.groupWalletById(walletId);
    if (wallet == null) return;

    final updated = wallet.copyWith(
      members: wallet.members.where((m) => m.id != memberId).toList(),
    );
    final wallets = bloc.groupWallets
        .map((w) => w.id == walletId ? updated : w)
        .toList();
    await _persist(wallets);

    // TODO: Call GroupWalletApi.removeMember(...) when backend is ready.
  }

  /// The owner deletes a group wallet.
  Future<void> deleteGroupWallet(String walletId) async {
    final wallet = bloc.groupWalletById(walletId);
    if (wallet == null) return;
    if (wallet.ownerId != systemBloc.phone) return;

    final wallets = bloc.groupWallets.where((w) => w.id != walletId).toList();
    await _persist(wallets);
  }

  Future<void> _persist(List<GroupWallet> wallets) async {
    bloc.setGroupWallets(wallets);
    await StorageService.saveGroupWallets(wallets);
  }
}
