import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Holds the user's bank cards, wallets and transactions in memory.
class WalletBloc extends ChangeNotifier {
  List<BankCard> _cards = [];
  List<MoMoWallet> _momo = [];
  List<Wallet> _wallets = [];
  String? _activeWalletId;
  List<WalletTransaction> _transactions = [];
  List<ActivityRecord> _activity = [];
  List<MoneyRequest> _moneyRequests = [];
  List<SplitPayment> _splits = [];
  List<GroupWallet> _groupWallets = [];
  List<CardShare> _cardShares = [];
  List<WithdrawalRequest> _withdrawalRequests = [];
  List<WalletDeposit> _walletDeposits = [];

  List<BankCard> get cards => List.unmodifiable(_cards);
  List<MoMoWallet> get momoWallets => List.unmodifiable(_momo);
  List<Wallet> get wallets => List.unmodifiable(_wallets);
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  List<ActivityRecord> get activity => List.unmodifiable(_activity);
  List<MoneyRequest> get moneyRequests => List.unmodifiable(_moneyRequests);
  List<SplitPayment> get splitPayments => List.unmodifiable(_splits);
  List<GroupWallet> get groupWallets => List.unmodifiable(_groupWallets);
  List<CardShare> get cardShares => List.unmodifiable(_cardShares);
  List<WithdrawalRequest> get withdrawalRequests => List.unmodifiable(_withdrawalRequests);
  List<WalletDeposit> get walletDeposits => List.unmodifiable(_walletDeposits);

  /// Requests waiting to be paid.
  List<MoneyRequest> get pendingRequests =>
      _moneyRequests.where((r) => r.isPending).toList();

  /// The wallet the user is currently viewing / acting on.
  Wallet get activeWallet {
    for (final w in _wallets) {
      if (w.id == _activeWalletId) return w;
    }
    if (_wallets.isNotEmpty) return _wallets.first;
    return Wallet(id: 'empty', name: 'My Wallet', createdAt: DateTime.now());
  }

  String? get activeWalletId => activeWallet.id;

  Wallet? walletById(String id) {
    for (final w in _wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  /// Combined value of every attached card.
  double get totalCardBalance =>
      _cards.fold(0, (sum, c) => sum + c.balance);

  /// Everything inside every wallet.
  double get walletTotal =>
      _wallets.fold(0, (sum, w) => sum + w.totalBalance);

  /// Number of pockets across all wallets.
  int get totalPockets =>
      _wallets.fold(0, (sum, w) => sum + w.subWallets.length);

  void setCards(List<BankCard> cards) {
    _cards = cards;
    notifyListeners();
  }

  void setMoMoWallets(List<MoMoWallet> wallets) {
    _momo = wallets;
    notifyListeners();
  }

  MoMoWallet? momoById(String id) {
    for (final w in _momo) {
      if (w.id == id) return w;
    }
    return null;
  }

  void setWallets(List<Wallet> wallets, {String? activeId}) {
    _wallets = wallets;
    if (activeId != null) {
      _activeWalletId = activeId;
    } else if (_wallets.isNotEmpty && _activeWalletId == null) {
      _activeWalletId = _wallets.first.id;
    }
    notifyListeners();
  }

  void setActiveWallet(String id) {
    if (_wallets.any((w) => w.id == id)) {
      _activeWalletId = id;
      notifyListeners();
    }
  }

  void setTransactions(List<WalletTransaction> txs) {
    _transactions = txs;
    notifyListeners();
  }

  BankCard? cardById(String id) {
    for (final c in _cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<WalletTransaction> transactionsFor(String walletId) =>
      _transactions.where((t) => t.walletId == walletId).toList();

  List<WalletDeposit> depositsFor(String walletId) =>
      _walletDeposits.where((d) => d.walletId == walletId).toList();

  void setWalletDeposits(List<WalletDeposit> deposits) {
    _walletDeposits = deposits;
    notifyListeners();
  }

  void setActivity(List<ActivityRecord> items) {
    _activity = items;
    notifyListeners();
  }

  void setMoneyRequests(List<MoneyRequest> requests) {
    _moneyRequests = requests;
    notifyListeners();
  }

  void setSplitPayments(List<SplitPayment> splits) {
    _splits = splits;
    notifyListeners();
  }

  void setGroupWallets(List<GroupWallet> wallets) {
    _groupWallets = wallets;
    notifyListeners();
  }

  GroupWallet? groupWalletById(String id) {
    for (final w in _groupWallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  /// Group wallets where the current user has a pending invitation.
  List<GroupWallet> get pendingGroupInvitations {
    final phone = systemBloc.phone;
    return _groupWallets.where((w) {
      return w.members.any((m) => m.phone == phone && m.isPending);
    }).toList();
  }

  void setCardShares(List<CardShare> shares) {
    _cardShares = shares;
    notifyListeners();
  }

  void setWithdrawalRequests(List<WithdrawalRequest> requests) {
    _withdrawalRequests = requests;
    notifyListeners();
  }

  /// Card shares where the current user is the invitee and hasn't answered.
  List<CardShare> get pendingShareInvitations {
    final phone = systemBloc.phone;
    return _cardShares
        .where((s) => s.inviteePhone == phone && s.isPending)
        .toList();
  }

  /// Card shares the current user accepted and now has access to.
  List<CardShare> get acceptedSharesWithMe {
    final phone = systemBloc.phone;
    return _cardShares
        .where((s) => s.inviteePhone == phone && s.isAccepted)
        .toList();
  }

  /// Shared cards resolved to live [BankCard]s for display. Balance always
  /// mirrors the owner's card on this device.
  List<BankCard> get sharedCardsWithMe {
    final phone = systemBloc.phone;
    final cards = <BankCard>[];
    for (final share in _cardShares) {
      if (share.inviteePhone != phone || !share.isAccepted) continue;
      final original = cardById(share.cardId);
      if (original == null) continue;
      cards.add(
        original.copyWith(
          nickname: '${original.nickname} (shared)',
          isPrimary: false,
          isShared: true,
        ),
      );
    }
    return cards;
  }

  /// Withdrawal requests on cards the current user owns, waiting for approval.
  List<WithdrawalRequest> get pendingWithdrawalApprovals {
    final phone = systemBloc.phone;
    return _withdrawalRequests
        .where((r) => r.ownerPhone == phone && r.isPending)
        .toList();
  }
}
